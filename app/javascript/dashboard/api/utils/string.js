const camelToSnakeCase = str =>
  str.replace(/[A-Z]/g, letter => `_${letter.toLowerCase()}`);

const convertObjectKeysToSnakeCase = obj => {
  const newObj = {};
  Object.keys(obj).forEach(key => {
    newObj[camelToSnakeCase(key)] = obj[key];
  });
  return newObj;
};

export { camelToSnakeCase, convertObjectKeysToSnakeCase };
