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
    private Label _selectedDateLabel;
    private GridContainer _daysGrid;
    private ButtonGroup _dayButtonGroup;

    private DateTime _currentDate = DateTime.Today;
    private DateTime _selectedDate = DateTime.Today;
    private bool _isReady = false;

    private readonly HebrewCalendar _hebrewCalendar = new HebrewCalendar();
    private readonly GregorianCalendar _gregorianCalendar = new GregorianCalendar();
    private readonly CultureInfo _hebrewCulture = new CultureInfo("he-IL");

    public override void _Ready()
    {
        _hebrewCulture.DateTimeFormat.Calendar = _hebrewCalendar;
        _prevMonthButton = GetNode<Button>("VBoxContainer/MarginContainer/Date/BackMonthButton");
        _nextMonthButton = GetNode<Button>("VBoxContainer/MarginContainer/Date/NextMonthButton");
        _monthYearLabel = GetNode<Label>("VBoxContainer/MarginContainer/Date/Label");
        _daysGrid = GetNode<GridContainer>("VBoxContainer/GridContainer");
        _selectedDateLabel = GetNode<Label>("VBoxContainer/DateLabel");
        _dayButtonGroup = ResourceLoader.Load<ButtonGroup>("res://resources/calendar_button_group.tres");


        _prevMonthButton.Pressed += () => ChangeMonth(-1);
        _nextMonthButton.Pressed += () => ChangeMonth(1);

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
            _monthYearLabel.Text = $"{GetHebrewMonthName(year, month)} {ToGematria(year)}";
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

                dayButton.Text = IsHebrew ? ToGematria(capturedDay) : capturedDay.ToString();
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
            int day = _hebrewCalendar.GetDayOfMonth(_selectedDate);
            int month = _hebrewCalendar.GetMonth(_selectedDate);
            int year = _hebrewCalendar.GetYear(_selectedDate);
            string dayOfWeek = _hebrewCulture.DateTimeFormat.GetDayName(_selectedDate.DayOfWeek);
            string monthName = GetHebrewMonthName(year, month);
            _selectedDateLabel.Text = $"{dayOfWeek} {ToGematria(day)} {monthName} {ToGematria(year)}";
        }
        else
        {
            _selectedDateLabel.Text = _selectedDate.ToString("dddd, dd MMMM yyyy");
        }
    }

    private string GetHebrewMonthName(int year, int month)
    {
        try
        {
            DateTime dt = _hebrewCalendar.ToDateTime(year, month, 1, 0, 0, 0, 0);
            // _hebrewCulture has been configured in _Ready() to use _hebrewCalendar.
            return dt.ToString("MMMM", _hebrewCulture);
        }
        catch (Exception ex)
        {
            GD.PrintErr($"Error in GetHebrewMonthName for year={year}, month={month}: {ex.Message}");
            // Fallback for safety, though the new method should be more reliable.
            return _hebrewCulture.DateTimeFormat.GetMonthName(month);
        }
    }

    private string ToGematria(int number)
    {
        if (number <= 0) return "";

        string result = "";
        int tempNum = number;

        // Handle thousands for year
        if (tempNum >= 1000)
        {
            result += ToGematria(tempNum / 1000) + "'";
            tempNum %= 1000;
        }

        if (tempNum >= 100)
        {
            while (tempNum >= 100)
            {
                if (tempNum >= 400) { result += 'ת'; tempNum -= 400; }
                else if (tempNum >= 300) { result += 'ש'; tempNum -= 300; }
                else if (tempNum >= 200) { result += 'ר'; tempNum -= 200; }
                else { result += 'ק'; tempNum -= 100; }
            }
        }

        string tensAndUnits = "";
        if (tempNum == 15) tensAndUnits = "טו";
        else if (tempNum == 16) tensAndUnits = "טז";
        else
        {
            switch (tempNum / 10)
            {
                case 1: tensAndUnits += 'י'; break;
                case 2: tensAndUnits += 'כ'; break;
                case 3: tensAndUnits += 'ל'; break;
                case 4: tensAndUnits += 'מ'; break;
                case 5: tensAndUnits += 'נ'; break;
                case 6: tensAndUnits += 'ס'; break;
                case 7: tensAndUnits += 'ע'; break;
                case 8: tensAndUnits += 'פ'; break;
                case 9: tensAndUnits += 'צ'; break;
            }
            switch (tempNum % 10)
            {
                case 1: tensAndUnits += 'א'; break;
                case 2: tensAndUnits += 'ב'; break;
                case 3: tensAndUnits += 'ג'; break;
                case 4: tensAndUnits += 'ד'; break;
                case 5: tensAndUnits += 'ה'; break;
                case 6: tensAndUnits += 'ו'; break;
                case 7: tensAndUnits += 'ז'; break;
                case 8: tensAndUnits += 'ח'; break;
                case 9: tensAndUnits += 'ט'; break;
            }
        }
        result += tensAndUnits;

        if (result.Length > 1 && !result.Contains("'"))
        {
            result = result.Insert(result.Length - 1, "'");
        }
        else if (result.Length == 1 && !result.Contains("'"))
        {
            result += "'";
        }


        return result;
    }
}
