using System;
using System.Collections.Generic;
using System.Runtime.InteropServices;
using System.Windows;
using System.Windows.Input;
using System.Windows.Interop;
using System.Windows.Threading;

namespace FocusMode
{
    public partial class MainWindow : Window
    {
        private bool _isFocusModeActive = false;
        private IntPtr _targetWindow = IntPtr.Zero;
        private List<OverlayWindow> _overlays = new List<OverlayWindow>();
        private DispatcherTimer _trackingTimer;
        private double _currentOpacity = 0.7;

        // 글로벌 핫키 ID
        private const int HOTKEY_ID = 9000;

        public MainWindow()
        {
            InitializeComponent();
            Loaded += MainWindow_Loaded;
            Closing += MainWindow_Closing;
        }

        private void MainWindow_Loaded(object sender, RoutedEventArgs e)
        {
            // 글로벌 핫키 등록 (Ctrl+Alt+F)
            var helper = new WindowInteropHelper(this);
            RegisterHotKey(helper.Handle, HOTKEY_ID, MOD_CONTROL | MOD_ALT, VK_F);

            // 핫키 메시지 처리
            HwndSource source = HwndSource.FromHwnd(helper.Handle);
            source.AddHook(HwndHook);

            // 창 추적 타이머 설정
            _trackingTimer = new DispatcherTimer();
            _trackingTimer.Interval = TimeSpan.FromMilliseconds(16); // ~60fps
            _trackingTimer.Tick += TrackingTimer_Tick;
        }

        private void MainWindow_Closing(object sender, System.ComponentModel.CancelEventArgs e)
        {
            // 핫키 해제
            var helper = new WindowInteropHelper(this);
            UnregisterHotKey(helper.Handle, HOTKEY_ID);

            // 오버레이 제거
            DeactivateFocusMode();
        }

        private IntPtr HwndHook(IntPtr hwnd, int msg, IntPtr wParam, IntPtr lParam, ref bool handled)
        {
            const int WM_HOTKEY = 0x0312;
            if (msg == WM_HOTKEY && wParam.ToInt32() == HOTKEY_ID)
            {
                ToggleFocusMode();
                handled = true;
            }
            return IntPtr.Zero;
        }

        public void ToggleFocusMode()
        {
            if (_isFocusModeActive)
            {
                DeactivateFocusMode();
            }
            else
            {
                ActivateFocusMode();
            }
        }

        private void ActivateFocusMode()
        {
            // 현재 활성 창 가져오기 (이 창은 제외)
            _targetWindow = GetForegroundWindow();
            var thisHandle = new WindowInteropHelper(this).Handle;

            if (_targetWindow == thisHandle || _targetWindow == IntPtr.Zero)
            {
                MessageBox.Show("집중할 창을 먼저 선택해주세요.", "집중 모드", MessageBoxButton.OK, MessageBoxImage.Information);
                return;
            }

            // 이 창 숨기기
            this.Hide();

            // 모든 모니터에 오버레이 생성
            CreateOverlays();

            // 타이머 시작
            _trackingTimer.Start();

            _isFocusModeActive = true;
            ToggleButton.Content = "집중 모드 종료";
        }

        public void DeactivateFocusMode()
        {
            _trackingTimer.Stop();

            // 오버레이 제거
            foreach (var overlay in _overlays)
            {
                overlay.Close();
            }
            _overlays.Clear();

            _targetWindow = IntPtr.Zero;
            _isFocusModeActive = false;
            ToggleButton.Content = "집중 모드 시작";
        }

        private void CreateOverlays()
        {
            // 기존 오버레이 제거
            foreach (var overlay in _overlays)
            {
                overlay.Close();
            }
            _overlays.Clear();

            // 모든 모니터에 오버레이 생성
            foreach (var screen in System.Windows.Forms.Screen.AllScreens)
            {
                var overlay = new OverlayWindow();
                overlay.SetBounds(screen.Bounds.Left, screen.Bounds.Top, screen.Bounds.Width, screen.Bounds.Height);
                overlay.SetOpacity(_currentOpacity);
                overlay.OnDoubleClick += Overlay_OnDoubleClick;
                overlay.Show();
                _overlays.Add(overlay);
            }

            // 초기 구멍 위치 설정
            UpdateHole();
        }

        private void Overlay_OnDoubleClick()
        {
            // 더블클릭으로 종료
            DeactivateFocusMode();
            this.Show();
            this.Activate();
        }

        private void TrackingTimer_Tick(object sender, EventArgs e)
        {
            if (!_isFocusModeActive || _targetWindow == IntPtr.Zero)
                return;

            // 창이 아직 존재하는지 확인
            if (!IsWindow(_targetWindow))
            {
                DeactivateFocusMode();
                this.Show();
                return;
            }

            UpdateHole();
        }

        private void UpdateHole()
        {
            if (_targetWindow == IntPtr.Zero)
                return;

            // 타겟 창의 위치와 크기 가져오기
            RECT rect;
            if (GetWindowRect(_targetWindow, out rect))
            {
                int x = rect.Left;
                int y = rect.Top;
                int width = rect.Right - rect.Left;
                int height = rect.Bottom - rect.Top;

                // 모든 오버레이에 구멍 위치 업데이트
                foreach (var overlay in _overlays)
                {
                    overlay.SetHole(x, y, width, height);
                }
            }
        }

        private void OpacitySlider_ValueChanged(object sender, RoutedPropertyChangedEventArgs<double> e)
        {
            if (OpacityText != null)
            {
                _currentOpacity = e.NewValue / 100.0;
                OpacityText.Text = $"{(int)e.NewValue}%";

                // 활성화된 오버레이에도 적용
                foreach (var overlay in _overlays)
                {
                    overlay.SetOpacity(_currentOpacity);
                }
            }
        }

        private void ToggleButton_Click(object sender, RoutedEventArgs e)
        {
            ToggleFocusMode();
        }

        private void HideButton_Click(object sender, RoutedEventArgs e)
        {
            this.Hide();
        }

        #region Win32 API

        private const int MOD_ALT = 0x0001;
        private const int MOD_CONTROL = 0x0002;
        private const int MOD_SHIFT = 0x0004;
        private const int VK_F = 0x46;

        [DllImport("user32.dll")]
        private static extern bool RegisterHotKey(IntPtr hWnd, int id, int fsModifiers, int vk);

        [DllImport("user32.dll")]
        private static extern bool UnregisterHotKey(IntPtr hWnd, int id);

        [DllImport("user32.dll")]
        private static extern IntPtr GetForegroundWindow();

        [DllImport("user32.dll")]
        private static extern bool GetWindowRect(IntPtr hWnd, out RECT lpRect);

        [DllImport("user32.dll")]
        private static extern bool IsWindow(IntPtr hWnd);

        [StructLayout(LayoutKind.Sequential)]
        private struct RECT
        {
            public int Left;
            public int Top;
            public int Right;
            public int Bottom;
        }

        #endregion
    }
}
