/**
 * Converts a Buffer to a Base64 Data URI string.
 */
export const bufferToBase64 = (buffer: Buffer, mimeType: string): string => {
  return `data:${mimeType};base64,${buffer.toString("base64")}`;
};

/**
 * Validates whether a string is a valid image base64 data URI or a valid URL.
 */
export const isValidAvatar = (str: string): boolean => {
  if (!str) return false;

  // Check if it's a URL (e.g. from Google Auth)
  if (str.startsWith("http://") || str.startsWith("https://")) {
    return true;
  }

  // Check if it's a valid Base64 image data URI
  // Schema: data:image/<type>;base64,<data>
  const base64Regex = /^data:image\/(jpeg|jpg|png|webp|gif);base64,([A-Za-z0-9+/=]+)$/;
  return base64Regex.test(str);
};

/**
 * Converts a Base64 Data URI string back to a Buffer and its mimeType.
 */
export const base64ToBuffer = (
  base64Str: string,
): { buffer: Buffer; mimeType: string } | null => {
  const base64Regex = /^data:image\/(jpeg|jpg|png|webp|gif);base64,([A-Za-z0-9+/=]+)$/;
  const matches = base64Str.match(base64Regex);
  if (!matches) return null;

  const mimeType = `image/${matches[1]}`;
  const buffer = Buffer.from(matches[2], "base64");
  return { buffer, mimeType };
};
