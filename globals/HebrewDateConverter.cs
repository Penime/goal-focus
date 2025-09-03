using Godot;
using System;
using System.Globalization;

public partial class HebrewDateConverter : Node
{
	private readonly HebrewCalendar _hebrewCalendar = new HebrewCalendar();
	private readonly CultureInfo _hebrewCulture = new CultureInfo("he-IL");

	/// <summary>
	/// Converts a Unix timestamp into a formatted Hebrew date string.
	/// </summary>
	/// <param name="unixTime">The Unix time in seconds.</param>
	/// <returns>A formatted Hebrew date string (e.g., "יום ראשון א' תשרי ה'תשפ"ד").</returns>
	public string GetHebrewDateStringFromUnix(long unixTime)
	{
		// The unixTime from CalendarComponent is a "fake" UTC time.
		// We need to convert it to a DateTime object *without* applying any local time zone conversion.
		DateTime dateTime = DateTimeOffset.FromUnixTimeSeconds(unixTime).UtcDateTime;
		return GetHebrewDateString(dateTime);
	}

	/// <summary>
	/// Converts a DateTime object into a formatted Hebrew date string.
	/// </summary>
	/// <param name="dateTime">The DateTime to convert.</param>
	/// <returns>A formatted Hebrew date string (e.g., "יום ראשון א' תשרי ה'תשפ"ד").</returns>
	public string GetHebrewDateString(DateTime dateTime)
	{
		var parts = GetDateParts(dateTime, true);
		return $"{parts["weekday"]} {parts["month_day"]} {parts["month"]} {parts["year"]}";
	}

	public Godot.Collections.Dictionary<string, string> GetDatePartsFromUnix(long unixTime, bool useHebrew)
	{
		// The unixTime from CalendarComponent is a "fake" UTC time.
		// We need to convert it to a DateTime object *without* applying any local time zone conversion.
		DateTime dateTime = DateTimeOffset.FromUnixTimeSeconds(unixTime).UtcDateTime;
		return GetDateParts(dateTime, useHebrew);
	}

	/// <summary>
	/// Gets a dictionary of date and time components for a given DateTime.
	/// </summary>
	/// <param name="dateTime">The DateTime to convert.</param>
	/// <param name="useHebrew">If true, returns Hebrew calendar parts. If false, returns Gregorian parts with Hebrew names.</param>
	/// <returns>A dictionary containing keys: year, month, month_day, weekday, hour, minutes.</returns>
	public Godot.Collections.Dictionary<string, string> GetDateParts(DateTime dateTime, bool useHebrew)
	{
		var parts = new Godot.Collections.Dictionary<string, string>();

		if (useHebrew)
		{
			int hebrewYear = _hebrewCalendar.GetYear(dateTime);
			int hebrewMonth = _hebrewCalendar.GetMonth(dateTime);
			int hebrewDay = _hebrewCalendar.GetDayOfMonth(dateTime);

			parts["year"] = ToGematria(hebrewYear);
			// In Hebrew mode, use the actual Hebrew month name (e.g., "אלול").
			parts["month"] = GetHebrewMonthName(hebrewYear, hebrewMonth);
			parts["month_day"] = ToGematria(hebrewDay);
		}
		else
		{
			// Gregorian date, but with Hebrew names for month/day as per user request.
			parts["year"] = dateTime.Year.ToString();
			parts["month"] = dateTime.ToString("MMMM", _hebrewCulture);
			parts["month_day"] = dateTime.Day.ToString();
		}

		parts["weekday"] = dateTime.ToString("dddd", _hebrewCulture).Replace("יום ", "");
		parts["hour"] = dateTime.Hour.ToString("D2");
		parts["minutes"] = dateTime.Minute.ToString("D2");

		return parts;
	}

	public string GetHebrewMonthName(int year, int month)
	{
		try
		{
			// Create a specific format provider for Hebrew calendar months to avoid side effects.
			// This is a "pure" function that doesn't rely on or change the state of _hebrewCulture.
			var hebrewFormatProvider = new CultureInfo("he-IL").DateTimeFormat;
			hebrewFormatProvider.Calendar = _hebrewCalendar;

			// We need a valid date to format. Let's use ToDateTime.
			DateTime dt = _hebrewCalendar.ToDateTime(year, month, 1, 0, 0, 0, 0);
			// This correctly handles leap years and Adar I/II.
			return dt.ToString("MMMM", hebrewFormatProvider);
		}
		catch (ArgumentOutOfRangeException ex)
		{
			// This can happen if an invalid month is passed (e.g., month 13 in a non-leap year).
			GD.PrintErr($"Error getting Hebrew month name for year={year}, month={month}: {ex.Message}");
			return "חודש לא תקין"; // "Invalid Month" in Hebrew
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