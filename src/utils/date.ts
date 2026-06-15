export function getCalendarDateString(
  date: Date,
  timezone?: string,
  offsetMinutes?: number
): string {
  if (timezone) {
    try {
      const formatter = new Intl.DateTimeFormat("en-US", {
        timeZone: timezone,
        year: "numeric",
        month: "2-digit",
        day: "2-digit",
      });
      const parts = formatter.formatToParts(date);
      const month = parts.find((p) => p.type === "month")?.value;
      const day = parts.find((p) => p.type === "day")?.value;
      const year = parts.find((p) => p.type === "year")?.value;
      if (month && day && year) {
        return `${year}-${month}-${day}`;
      }
    } catch (e) {
      // Fallback to offset or UTC on formatting error
    }
  }

  if (offsetMinutes !== undefined && !isNaN(offsetMinutes)) {
    // offsetMinutes is UTC minus Local (in minutes)
    // localTime = UTC - offsetMinutes
    const localTime = new Date(date.getTime() - offsetMinutes * 60 * 1000);
    return localTime.toISOString().split("T")[0];
  }

  return date.toISOString().split("T")[0];
}
