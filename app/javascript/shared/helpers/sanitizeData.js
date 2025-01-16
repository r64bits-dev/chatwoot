export const labelSanitizePattern = /[^a-zA-Z0-9_-]/g;
export const spacesPattern = /\s+/g;

/**
 * Sanitizes a label by removing unwanted characters and replacing spaces with hyphens.
 *
 * @param {string | undefined | null} label - The label to sanitize.
 * @returns {string} The sanitized label.
 *
 * @example
 * const label = 'My Label 123';
 * const sanitizedLabel = sanitizeLabel(label); // 'my-label-123'
 */
export const sanitizeLabel = (label = '') => {
  if (!label) return '';

  return label
    .trim()
    .toLowerCase()
    .replace(spacesPattern, '-')
    .replace(labelSanitizePattern, '');
};

/**
 * Sanitizes a phone number by removing unwanted characters and replacing spaces with hyphens.
 *
 * @param {string | undefined | null} phoneNumber - The phone number to sanitize.
 * @returns {string} The sanitized phone number.
 *
 * @example
 * const phoneNumber = '+5511987654321';
 * const sanitizedPhoneNumber = sanitizePhoneNumber(phoneNumber); // '+55(11) 98765-4321'
 */
export const sanitizePhoneNumber = phoneNumber => {
  if (!phoneNumber) return '';

  // Remove all non-numeric characters except '+'
  const cleaned = phoneNumber.replace(/[^\d+]/g, '');

  // Match the number parts (country code, area code, and local number)
  const match = cleaned.match(/^\+?(\d{2})(\d{2})(\d{5})(\d{4})$/);
  if (!match) return cleaned; // Return cleaned input if it doesn't match expected format

  const [, countryCode, areaCode, part1, part2] = match;
  return `+${countryCode}(${areaCode}) ${part1}-${part2}`;
};
