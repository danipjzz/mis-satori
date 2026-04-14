process.env.NODE_TLS_REJECT_UNAUTHORIZED = "0";

const { Pool } = require("pg");

const pool = new Pool({
  connectionString: process.env.DATABASE_URL,
  ssl: {
    require: true,
    rejectUnauthorized: false
  }
});

module.exports = pool;