const crypto = require('crypto');

function generateSecureToken() {
  return crypto.randomBytes(32).toString('base64url');
}

function hashToken(token) {
  return crypto.createHash('sha256').update(token, 'utf8').digest('hex');
}

function tokensMatch(plainToken, storedHash) {
  const computed = hashToken(plainToken);
  const a = Buffer.from(computed, 'hex');
  const b = Buffer.from(storedHash, 'hex');
  if (a.length !== b.length) {
    return false;
  }
  return crypto.timingSafeEqual(a, b);
}

module.exports = { generateSecureToken, hashToken, tokensMatch };
