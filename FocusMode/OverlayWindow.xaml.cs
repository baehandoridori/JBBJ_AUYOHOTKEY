using System;
using System.Runtime.InteropServices;
using System.Windows;
using System.Windows.Input;
using System.Windows.Interop;
using System.Windows.Media;

namespace FocusMode
{
    public partial class OverlayWindow : Window
    {
        public event Action OnDoubleClick;

        private int _screenX, _screenY, _screenWidth, _screenHeight;
        private DateTime _lastClickTime = DateTime.MinValue;
        private const int DOUBLE_CLICK_TIME = 300; // ms

        public OverlayWindow()
        {
            InitializeComponent();
            Loaded += OverlayWindow_Loaded;
            MouseLeftButtonDown += OverlayWindow_MouseLeftButtonDown;
        }

        private void OverlayWindow_Loaded(object sender, RoutedEventArgs e)
        {
            // 클릭 통과 설정 제거 (클릭을 받아야 더블클릭 감지 가능)
            // 대신 클릭 시 아무 동작도 하지 않음
            MakeClickThrough(false);
        }

        private void MakeClickThrough(bool enable)
        {
            var hwnd = new WindowInteropHelper(this).Handle;
            int extendedStyle = GetWindowLong(hwnd, GWL_EXSTYLE);

            if (enable)
            {
                // 클릭 통과 활성화
                SetWindowLong(hwnd, GWL_EXSTYLE, extendedStyle | WS_EX_TRANSPARENT);
            }
            else
            {
                // 클릭 통과 비활성화 (클릭 받음)
                SetWindowLong(hwnd, GWL_EXSTYLE, extendedStyle & ~WS_EX_TRANSPARENT);
            }
        }

        private void OverlayWindow_MouseLeftButtonDown(object sender, MouseButtonEventArgs e)
        {
            // 더블클릭 감지
            var now = DateTime.Now;
            var diff = (now - _lastClickTime).TotalMilliseconds;

            if (diff < DOUBLE_CLICK_TIME)
            {
                // 더블클릭!
                OnDoubleClick?.Invoke();
                _lastClickTime = DateTime.MinValue;
            }
            else
            {
                _lastClickTime = now;
            }

            // 클릭은 무시 (아무 동작 안 함)
            e.Handled = true;
        }

        public void SetBounds(int x, int y, int width, int height)
        {
            _screenX = x;
            _screenY = y;
            _screenWidth = width;
            _screenHeight = height;

            this.Left = x;
            this.Top = y;
            this.Width = width;
            this.Height = height;

            // 전체 화면 사각형 설정
            var fullScreenRect = (RectangleGeometry)((CombinedGeometry)OverlayPath.Data).Geometry1;
            fullScreenRect.Rect = new Rect(0, 0, width, height);
        }

        public void SetHole(int x, int y, int width, int height)
        {
            // 스크린 좌표를 이 오버레이의 로컬 좌표로 변환
            int localX = x - _screenX;
            int localY = y - _screenY;

            // 구멍 사각형 설정
            var holeRect = (RectangleGeometry)((CombinedGeometry)OverlayPath.Data).Geometry2;
            holeRect.Rect = new Rect(localX, localY, width, height);
        }

        public void SetOpacity(double opacity)
        {
            OverlayPath.Opacity = opacity;
        }

        #region Win32 API

        private const int GWL_EXSTYLE = -20;
        private const int WS_EX_TRANSPARENT = 0x00000020;

        [DllImport("user32.dll")]
        private static extern int GetWindowLong(IntPtr hwnd, int index);

        [DllImport("user32.dll")]
        private static extern int SetWindowLong(IntPtr hwnd, int index, int newStyle);

        #endregion
    }
}
