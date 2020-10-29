const express = require('express');
const { createProxyMiddleware } = require('http-proxy-middleware');
const https = require('https');
const morgan = require('morgan');

const app = express();
const port = 8080;

// Enable request logging.
app.use(morgan('tiny'));

// Setup all the proxy routes.

app.use(
  '/',
  createProxyMiddleware({
    target: 'https://linode.coursetable.com',
    headers: {
      host: 'coursetable.com',
    },
  })
);

app.listen(port, () => {
  console.log(`old proxy listening on port ${port}`);
});
