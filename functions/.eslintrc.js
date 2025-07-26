module.exports = {
  env: {
    es6: true,
    node: true,
  },
  parserOptions: {
    ecmaVersion: 2018,
  },
  extends: [
    "eslint:recommended",
  ],
  rules: {
    "quotes": "off",
    "indent": "off",
    "max-len": "off",
    "require-jsdoc": "off",
    "object-curly-spacing": "off",
    "no-trailing-spaces": "off",
    "eol-last": "off",
    "arrow-parens": "off",
    "padded-blocks": "off",
    "no-unused-vars": "warn",
    "no-restricted-globals": ["error", "name", "length"],
    "prefer-arrow-callback": "error",
  },
  globals: {},
};