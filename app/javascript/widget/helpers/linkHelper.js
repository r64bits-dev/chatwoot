import { helpers } from 'vuelidate/lib/validators';

/**
 * Valida se o valor é uma URL válida.
 * @type {Function}
 */
export const validUrl = helpers.regex(
  'validUrl',
  /^(https?|ftp):\/\/[^\s/$.?#].[^\s]*$/
);
