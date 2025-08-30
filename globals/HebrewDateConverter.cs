using Godot;
using System;
using System.Globalization;

public partial class HebrewDateConverter : Node
{
	private readonly HebrewCalendar _hebrewCalendar = new HebrewCalendar();
	private readonly CultureInfo _hebrewCulture = new CultureInfo("he-IL");

	public override void _Ready()
	{
		_hebrewCulture.DateTimeFormat.Calendar = _hebrewCalendar;
	}

	/// <summary>
	/// Converts a Unix timestamp into a formatted Hebrew date string.
	/// </summary>
	/// <param name="unixTime">The Unix time in seconds.</param>
	/// <returns>A formatted Hebrew date string (e.g., "יום ראשון א' תשרי ה'תשפ"ד").</returns>
	public string GetHebrewDateStringFromUnix(long unixTime)
	{
		DateTime dateTime = DateTimeOffset.FromUnixTimeSeconds(unixTime).LocalDateTime;
		return GetHebrewDateString(dateTime);
	}

	/// <summary>
	/// Converts a DateTime object into a formatted Hebrew date string.
	/// </summary>
	/// <param name="dateTime">The DateTime to convert.</param>
	/// <returns>A formatted Hebrew date string (e.g., "יום ראשון א' תשרי ה'תשפ"ד").</returns>
	public string GetHebrewDateString(DateTime dateTime)
	{
		int day = _hebrewCalendar.GetDayOfMonth(dateTime);
		int month = _hebrewCalendar.GetMonth(dateTime);
		int year = _hebrewCalendar.GetYear(dateTime);
		string dayOfWeek = _hebrewCulture.DateTimeFormat.GetDayName(dateTime.DayOfWeek);
		string monthName = GetHebrewMonthName(year, month);

		return $"{dayOfWeek} {ToGematria(day)} {monthName} {ToGematria(year)}";
	}

	public string GetHebrewMonthName(int year, int month)
	{
		try
		{
			DateTime dt = _hebrewCalendar.ToDateTime(year, month, 1, 0, 0, 0, 0);
			return dt.ToString("MMMM", _hebrewCulture);
		}
		catch (Exception ex)
		{
			GD.PrintErr($"Error in GetHebrewMonthName for year={year}, month={month}: {ex.Message}");
			return _hebrewCulture.DateTimeFormat.GetMonthName(month);
		}
	}

	public string ToGematria(int number)
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
				case 1: tensAndUnits += 'י'; break; case 2: tensAndUnits += 'כ'; break;
				case 3: tensAndUnits += 'ל'; break; case 4: tensAndUnits += 'מ'; break;
				case 5: tensAndUnits += 'נ'; break; case 6: tensAndUnits += 'ס'; break;
				case 7: tensAndUnits += 'ע'; break; case 8: tensAndUnits += 'פ'; break;
				case 9: tensAndUnits += 'צ'; break;
			}
			switch (tempNum % 10)
			{
				case 1: tensAndUnits += 'א'; break; case 2: tensAndUnits += 'ב'; break;
				case 3: tensAndUnits += 'ג'; break; case 4: tensAndUnits += 'ד'; break;
				case 5: tensAndUnits += 'ה'; break; case 6: tensAndUnits += 'ו'; break;
				case 7: tensAndUnits += 'ז'; break; case 8: tensAndUnits += 'ח'; break;
				case 9: tensAndUnits += 'ט'; break;
			}
		}
		result += tensAndUnits;

		if (result.Length > 1 && !result.Contains("'")) { result = result.Insert(result.Length - 1, "'"); }
		else if (result.Length == 1 && !result.Contains("'")) { result += "'"; }

		return result;
	}
}