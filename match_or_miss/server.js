// server.js — Gemini API Proxy
const http = require('http');
const https = require('https');

const PORT = 3000;
const GEMINI_API_KEY = process.env.GEMINI_API_KEY || '';

const server = http.createServer((req, res) => {
  res.setHeader('Access-Control-Allow-Origin', '*');
  res.setHeader('Access-Control-Allow-Methods', 'POST, OPTIONS');
  res.setHeader('Access-Control-Allow-Headers', 'Content-Type');

  if (req.method === 'OPTIONS') {
    res.writeHead(204);
    res.end();
    return;
  }

  if (req.method === 'POST' && req.url === '/ai') {
    let body = '';
    req.on('data', chunk => body += chunk);
    req.on('end', () => {
      try {
        const { prompt } = JSON.parse(body);

        const payload = JSON.stringify({
          contents: [
            {
              parts: [
                {
                  text: prompt
                }
              ]
            }
          ],
          generationConfig: {
            maxOutputTokens: 500,
            temperature: 0.7,
          }
        });

        const options = {
          hostname: 'generativelanguage.googleapis.com',
          path: `/v1beta/models/gemini-2.5-flash-lite:generateContent?key=${GEMINI_API_KEY}`,
          method: 'POST',
          headers: {
            'Content-Type': 'application/json',
            'Content-Length': Buffer.byteLength(payload),
          },
        };

        const req2 = https.request(options, (res2) => {
          let data = '';
          console.log('📥 OpenAI HTTP status:', res2.statusCode);
          res2.on('data', chunk => data += chunk);
          res2.on('end', () => {
            try {
              const parsed = JSON.parse(data);
              const text = parsed.candidates?.[0]?.content?.parts?.[0]?.text ?? '';
              const finishReason = parsed.candidates?.[0]?.finishReason ?? 'unknown';
              const usageTokens = parsed.usageMetadata ?? {};
              console.log('✅ Gemini full response:', text);
              console.log('🏁 Finish reason:', finishReason);
              console.log('📊 Token usage:', JSON.stringify(usageTokens));
              if (finishReason === 'MAX_TOKENS') {
                console.warn('⚠️ Response was cut off by token limit! Increase maxOutputTokens.');
              }
              res.writeHead(200, { 'Content-Type': 'application/json' });
              res.end(JSON.stringify({ insight: text }));
            } catch (e) {
              console.error('❌ Parse error:', e.message);
              console.error('Raw:', data.substring(0, 300));
              res.writeHead(500);
              res.end(JSON.stringify({ error: 'Parse error' }));
            }
          });
        });

        req2.on('error', (e) => {
          console.error('❌ Request error:', e.message);
          res.writeHead(500);
          res.end(JSON.stringify({ error: e.message }));
        });

        req2.write(payload);
        req2.end();
      } catch (e) {
        console.error('❌ Body parse error:', e.message);
        res.writeHead(400);
        res.end(JSON.stringify({ error: 'Bad request' }));
      }
    });
  } else {
    res.writeHead(404);
    res.end(JSON.stringify({ error: 'Not found' }));
  }
});

server.listen(PORT, () => {
  console.log(`🚀 Proxy running at http://localhost:${PORT}`);
  console.log(`📡 Forwarding to Gemini API (gemini-2.5-flash-lite)`);
  if (!GEMINI_API_KEY) {
    console.warn('⚠️  GEMINI_API_KEY not set! Run: $env:GEMINI_API_KEY="your_key"; node server.js');
  } else {
    console.log(`🔑 Key: ${GEMINI_API_KEY.substring(0, 12)}...`);
  }
});