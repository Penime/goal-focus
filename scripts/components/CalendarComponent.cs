using Godot;
using System;
using System.Globalization;

public partial class CalendarComponent : Panel
{
	[Signal]
	public delegate void DateSelectedEventHandler(string dateString, long unixTime);

	private bool _isHebrew = false;
	[Export]
	public bool IsHebrew
	{
		get => _isHebrew;
		set
		{
			_isHebrew = value;
			if (_isReady)
			{
				DrawCalendar();
			}
		}
	}

	private Button _prevMonthButton;
	private Button _nextMonthButton;
	private Label _monthYearLabel;
	private Button _selectedDateLabel;
	private GridContainer _daysGrid;
	private CheckBox _hebrewCheckBox;
	private Button _todayButton;
	private ButtonGroup _dayButtonGroup;

	private DateTime _currentDate = DateTime.Today;
	private DateTime _selectedDate = DateTime.Today;
	private bool _isReady = false;

	private readonly HebrewCalendar _hebrewCalendar = new HebrewCalendar();
	private readonly GregorianCalendar _gregorianCalendar = new GregorianCalendar();
	private readonly CultureInfo _hebrewCulture = new CultureInfo("he-IL");

	private HebrewDateConverter _hebrewDateConverter;

	public override void _Ready()
	{
		_hebrewCulture.DateTimeFormat.Calendar = _hebrewCalendar;
		_prevMonthButton = GetNode<Button>("VBoxContainer/MarginContainer/Date/BackMonthButton");
		_nextMonthButton = GetNode<Button>("VBoxContainer/MarginContainer/Date/NextMonthButton");
		_hebrewDateConverter = GetNode<HebrewDateConverter>("/root/HebrewDateConverter");
		_monthYearLabel = GetNode<Label>("VBoxContainer/MarginContainer/Date/Label");
		_daysGrid = GetNode<GridContainer>("VBoxContainer/GridContainer");
		_selectedDateLabel = GetNode<Button>("VBoxContainer/DateButton");
		_hebrewCheckBox = GetNode<CheckBox>("VBoxContainer/CalendarControl/CheckBox");
		_todayButton = GetNode<Button>("VBoxContainer/CalendarControl/Button");
		_dayButtonGroup = ResourceLoader.Load<ButtonGroup>("res://resources/calendar_button_group.tres");


		_prevMonthButton.Pressed += () => ChangeMonth(-1);
		_nextMonthButton.Pressed += () => ChangeMonth(1);
		_todayButton.Pressed += GoToToday;

		_hebrewCheckBox.ButtonPressed = IsHebrew;
		_hebrewCheckBox.Toggled += OnHebrewCheckToggled;

		_isReady = true;
		DrawCalendar();
		UpdateSelectedDateLabel();
	}

	private void ChangeMonth(int direction)
	{
		if (IsHebrew)
		{
			_currentDate = _hebrewCalendar.AddMonths(_currentDate, direction);
		}
		else
		{
			_currentDate = _currentDate.AddMonths(direction);
		}
		DrawCalendar();
	}

	private void DrawCalendar()
	{
		GD.Print("--- Drawing Calendar ---");
		// Clear previous buttons
		foreach (Node child in _daysGrid.GetChildren())
		{
			child.QueueFree();
		}

		int year, month;
		Calendar cal;

		if (IsHebrew)
		{
			year = _hebrewCalendar.GetYear(_currentDate);
			month = _hebrewCalendar.GetMonth(_currentDate);
			cal = _hebrewCalendar;
			GD.Print($"Hebrew Date: Year={year}, Month={month}, Day={_hebrewCalendar.GetDayOfMonth(_currentDate)}");
			_monthYearLabel.Text = $"{_hebrewDateConverter.GetHebrewMonthName(year, month)} {_hebrewDateConverter.ToGematria(year)}";
		}
		else
		{
			year = _currentDate.Year;
			month = _currentDate.Month;
			cal = _gregorianCalendar;
			GD.Print($"Gregorian Date: Year={year}, Month={month}, Day={_currentDate.Day}");
			_monthYearLabel.Text = _currentDate.ToString("MMMM yyyy");
		}

		int daysInMonth = cal.GetDaysInMonth(year, month);
		GD.Print($"Days in month: {daysInMonth}");
		DateTime firstDayOfMonth;
		try
		{
			firstDayOfMonth = new DateTime(year, month, 1, cal);
		}
		catch (Exception e)
		{
			GD.PrintErr($"Error creating firstDayOfMonth: {e.Message}");
			GD.PrintErr($"Year={year}, Month={month}, Calendar={cal.GetType().Name}");
			return; // Stop drawing if we can't determine the first day
		}

		int firstDayOfWeek = (int)cal.GetDayOfWeek(firstDayOfMonth);
		GD.Print($"First day of week: {firstDayOfWeek}");

		for (int i = 0; i < 42; i++)
		{
			var dayButton = new Button();
			dayButton.ThemeTypeVariation = "CalendarButton";
			dayButton.ToggleMode = true;
			dayButton.ButtonGroup = _dayButtonGroup;

			int currentDay = i - firstDayOfWeek + 1;

			if (currentDay > 0 && currentDay <= daysInMonth)
			{
				int capturedDay = currentDay;
				int capturedYear = year;
				int capturedMonth = month;

				dayButton.Text = IsHebrew ? _hebrewDateConverter.ToGematria(capturedDay) : capturedDay.ToString();
				dayButton.Pressed += () => OnDayButtonPressed(capturedDay, capturedYear, capturedMonth);

				try
				{
					DateTime buttonDate = new DateTime(capturedYear, capturedMonth, capturedDay, cal);
					if (buttonDate.Date == _selectedDate.Date)
					{
						dayButton.ButtonPressed = true;
					}
				}
				catch (Exception e)
				{
					GD.PrintErr($"Error creating buttonDate for day {capturedDay}: {e.Message}");
				}
			}
			else
			{
				dayButton.Text = "";
				dayButton.Disabled = true;
			}
			_daysGrid.AddChild(dayButton);
		}
		GD.Print("--- Finished Drawing Calendar ---");
	}

	private void OnDayButtonPressed(int day, int year, int month)
	{
		Calendar cal = IsHebrew ? (Calendar)_hebrewCalendar : (Calendar)_gregorianCalendar;
		GD.Print($"OnDayButtonPressed: Year={year}, Month={month}, Day={day}, Calendar={cal.GetType().Name}");
		try
		{
			_selectedDate = new DateTime(year, month, day, cal);
			GD.Print($"Successfully created _selectedDate: {_selectedDate}");
			UpdateSelectedDateLabel();
			long unixTime = ((DateTimeOffset)_selectedDate).ToUnixTimeSeconds();
			EmitSignal(SignalName.DateSelected, _selectedDateLabel.Text, unixTime);
		}
		catch (Exception e)
		{
			GD.PrintErr($"CRITICAL: Error creating DateTime in OnDayButtonPressed: {e.Message}");
			GD.PrintErr($"Year={year}, Month={month}, Day={day}, Calendar={cal.GetType().Name}");
			int daysInMonth = cal.GetDaysInMonth(year, month);
			GD.PrintErr($"Days in this month: {daysInMonth}");
		}
	}

	private void UpdateSelectedDateLabel()
	{
		if (IsHebrew)
		{
			_selectedDateLabel.Text = _hebrewDateConverter.GetHebrewDateString(_selectedDate);
		}
		else
		{
			_selectedDateLabel.Text = _selectedDate.ToString("dddd, dd MMMM yyyy");
		}
	}

	private void OnHebrewCheckToggled(bool isToggled)
	{
		IsHebrew = isToggled;
		// The setter for IsHebrew calls DrawCalendar().
		// We also need to update the bottom label which shows the full selected date.
		UpdateSelectedDateLabel();
	}

	private void GoToToday()
	{
		_currentDate = DateTime.Today;
		_selectedDate = DateTime.Today;
		DrawCalendar();
		UpdateSelectedDateLabel();
		// Emit signal to notify other components of the date change
		long unixTime = ((DateTimeOffset)_selectedDate).ToUnixTimeSeconds();
		EmitSignal(SignalName.DateSelected, _selectedDateLabel.Text, unixTime);
	}
}
