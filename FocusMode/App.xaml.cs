using System;
using System.Windows;

namespace FocusMode
{
    public partial class App : Application
    {
        private System.Windows.Forms.NotifyIcon _trayIcon;

        protected override void OnStartup(StartupEventArgs e)
        {
            base.OnStartup(e);

            // 트레이 아이콘 설정
            _trayIcon = new System.Windows.Forms.NotifyIcon();
            _trayIcon.Icon = System.Drawing.SystemIcons.Application;
            _trayIcon.Text = "집중 모드 (Ctrl+Alt+F)";
            _trayIcon.Visible = true;

            // 트레이 메뉴
            var contextMenu = new System.Windows.Forms.ContextMenuStrip();
            contextMenu.Items.Add("설정 열기", null, (s, args) => ShowSettingsWindow());
            contextMenu.Items.Add("집중 모드 켜기/끄기", null, (s, args) => ToggleFocusMode());
            contextMenu.Items.Add("-");
            contextMenu.Items.Add("종료", null, (s, args) => ExitApplication());
            _trayIcon.ContextMenuStrip = contextMenu;

            // 더블클릭 시 설정 창 열기
            _trayIcon.DoubleClick += (s, args) => ShowSettingsWindow();
        }

        private void ShowSettingsWindow()
        {
            var mainWindow = MainWindow as MainWindow;
            if (mainWindow != null)
            {
                mainWindow.Show();
                mainWindow.WindowState = WindowState.Normal;
                mainWindow.Activate();
            }
        }

        private void ToggleFocusMode()
        {
            var mainWindow = MainWindow as MainWindow;
            mainWindow?.ToggleFocusMode();
        }

        private void ExitApplication()
        {
            _trayIcon.Visible = false;
            _trayIcon.Dispose();
            Shutdown();
        }

        protected override void OnExit(ExitEventArgs e)
        {
            if (_trayIcon != null)
            {
                _trayIcon.Visible = false;
                _trayIcon.Dispose();
            }
            base.OnExit(e);
        }
    }
}
