module.exports = {
  env: {
    es6: true,
    node: true,
  },
  parserOptions: {
    "ecmaVersion": 2018,
  },
  extends: [
    "eslint:recommended",
    "google",
  ],
  rules: {
    "no-restricted-globals": ["error", "name", "length"],
    "prefer-arrow-callback": "error",
    "quotes": ["error", "double", { "allowTemplateLiterals": true }],
  },
  overrides: [
    {
      files: ["**/*.spec.*"],
      env: {
        mocha: true,
      },
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
      },
    },
  ],
  globals: {},
};
