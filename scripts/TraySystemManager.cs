using Godot;
using System;
using System.Windows.Forms;
using System.Runtime.InteropServices;
using System.IO;

public partial class TraySystemManager : Node
{
	private NotifyIcon _notifyIcon;
	private bool _isTrayActive = false;
	private IntPtr _hWnd;

	private bool _isWindowVisible = true;
	private ToolStripMenuItem _showHideMenuItem;

	[DllImport("user32.dll")]
	private static extern bool ShowWindow(IntPtr hWnd, int nCmdShow);

	private const int SW_HIDE = 0;
	private const int SW_SHOW = 5;
	private const int SW_MINIMIZE = 6;
	private const int SW_RESTORE = 9;

	public override void _Ready()
	{
		if (OS.GetName() == "Windows")
		{
			_hWnd = (IntPtr)DisplayServer.WindowGetNativeHandle(DisplayServer.HandleType.WindowHandle);

			if (_hWnd == IntPtr.Zero)
			{
				GD.PushError("Failed to get native window handle. Tray hiding might not work correctly.");
			}
			else
			{
				GD.Print($"Native window handle obtained: {_hWnd}");
			}

			SetupTrayIcon();
			_isTrayActive = true;
			GD.Print("System tray manager initialized for Windows.");

			GetTree().AutoAcceptQuit = false; // Prevents app from quitting on X press

			GetTree().Root.Connect("tree_exiting", Callable.From(OnGodotTreeExiting));

			UpdateTrayContextMenu();
		}
		else
		{
			GD.Print($"System tray not supported on {OS.GetName()}.");
		}
	}

	private void SetupTrayIcon()
	{
		try
		{
			_notifyIcon = new NotifyIcon();

			string executableDir = OS.GetExecutablePath().GetBaseDir();
			string iconFileName = "img.ico";
			string iconPath = Path.Combine(executableDir, iconFileName);

			if (File.Exists(iconPath))
			{
				_notifyIcon.Icon = new System.Drawing.Icon(iconPath);
				GD.Print($"Loaded tray icon from: {iconPath}");
			}
			else
			{
				GD.PushError($"ERROR: Tray icon file not found at: {iconPath}. Please ensure '{iconFileName}' is in the same directory as your exported executable.");
				_notifyIcon.Icon = System.Drawing.SystemIcons.Application;
			}

			_notifyIcon.Visible = true;
			_notifyIcon.Text = "My Godot App in Tray";

			ContextMenuStrip contextMenu = new ContextMenuStrip();

			_showHideMenuItem = new ToolStripMenuItem();
			_showHideMenuItem.Click += (sender, e) =>
			{
				if (_isWindowVisible)
				{
					HideMainWindow();
				}
				else
				{
					ShowMainWindow();
				}
			};
			contextMenu.Items.Add(_showHideMenuItem);

			contextMenu.Items.Add("Quit Application", null, (sender, e) => GetTree().Quit());

			_notifyIcon.ContextMenuStrip = contextMenu;

			_notifyIcon.DoubleClick += (sender, e) => ShowMainWindow();

			contextMenu.Opening += (sender, e) => UpdateTrayContextMenu();

		}
		catch (Exception ex)
		{
			GD.PushError($"Failed to set up tray icon: {ex.Message}");
			_isTrayActive = false;
		}
	}

	private void UpdateTrayContextMenu()
	{
		if (_showHideMenuItem != null)
		{
			_showHideMenuItem.Text = _isWindowVisible ? "Hide Window" : "Show Window";
		}
	}

	private void ShowMainWindow()
	{
		if (_hWnd != IntPtr.Zero)
		{
			ShowWindow(_hWnd, SW_SHOW);
			ShowWindow(_hWnd, SW_RESTORE);

			DisplayServer.WindowSetMode(DisplayServer.WindowMode.Windowed);
			DisplayServer.WindowSetFlag(DisplayServer.WindowFlags.AlwaysOnTop, true);
			DisplayServer.WindowSetFlag(DisplayServer.WindowFlags.AlwaysOnTop, false);
		}
		else
		{
			DisplayServer.WindowSetMode(DisplayServer.WindowMode.Windowed);
		}
		_isWindowVisible = true;
		UpdateTrayContextMenu();
	}

	public override void _Notification(int what)
	{
		if (OS.GetName() == "Windows" && _isTrayActive)
		{
			if (what == 1048) // Corresponds to MainLoop.NotificationWmWindowMinimized
			{
				HideMainWindow();
			}
			else if (what == 1006) // Handling WindowCloseRequest
			{
				GD.Print("NotificationWmWindowCloseRequest (1006) received - Hiding window.");
				HideMainWindow();
			}
			else
			{
				GD.Print($"Unhandled notification received: {what}");
			}
		}
	}

	public void HideMainWindow()
	{
		if (OS.GetName() == "Windows" && _isTrayActive && _hWnd != IntPtr.Zero)
		{
			ShowWindow(_hWnd, SW_HIDE);
			GD.Print("Godot window hidden to tray via native API.");
		}
		else if (OS.GetName() == "Windows" && _isTrayActive)
		{
			DisplayServer.WindowSetMode(DisplayServer.WindowMode.Minimized);
			GD.Print("Godot window minimized to taskbar (native hide failed).");
		}
		_isWindowVisible = false;
		UpdateTrayContextMenu();
	}

	private void OnGodotTreeExiting()
	{
		if (_notifyIcon != null)
		{
			_notifyIcon.Visible = false;
			_notifyIcon.Dispose();
			_notifyIcon = null;
			GD.Print("System tray icon disposed.");
		}
	}
}
