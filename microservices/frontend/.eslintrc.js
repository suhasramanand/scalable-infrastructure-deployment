module.exports = {
  extends: [
    'react-app',
    'react-app/jest',
  ],
  rules: {
    'no-unused-vars': 'warn',
    'no-console': 'warn',
  },
  env: {
    browser: true,
    node: true,
    es6: true,
  },
};
