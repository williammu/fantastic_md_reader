const net = require('net');
const fs = require('fs');
const path = require('path');

const PORT = 8080;
const LOG_DIR = path.join(__dirname, 'logs');

// 确保日志目录存在
if (!fs.existsSync(LOG_DIR)) {
  fs.mkdirSync(LOG_DIR, { recursive: true });
}

// 创建 TCP 服务器
const server = net.createServer((socket) => {
  const clientAddress = `${socket.remoteAddress}:${socket.remotePort}`;
  console.log(`[Server] New connection from ${clientAddress}`);

  let dataBuffer = '';

  socket.on('data', (data) => {
    dataBuffer += data.toString();
  });

  socket.on('end', () => {
    console.log(`[Server] Connection closed from ${clientAddress}`);
    
    if (dataBuffer.length > 0) {
      // 保存接收到的数据
      const timestamp = new Date().toISOString().replace(/[:.]/g, '-');
      const logFile = path.join(LOG_DIR, `html_log_${timestamp}.html`);
      
      fs.writeFileSync(logFile, dataBuffer);
      console.log(`[Server] Saved HTML to: ${logFile}`);
      console.log(`[Server] Content length: ${dataBuffer.length} bytes`);
      
      // 同时输出到控制台（前500字符）
      console.log('[Server] Content preview:');
      console.log(dataBuffer.substring(0, 500));
      console.log('...');
    }
  });

  socket.on('error', (err) => {
    console.error(`[Server] Socket error: ${err.message}`);
  });
});

server.listen(PORT, '0.0.0.0', () => {
  console.log(`[Server] Log server started on port ${PORT}`);
  console.log(`[Server] Waiting for connections...`);
  console.log(`[Server] Logs will be saved to: ${LOG_DIR}`);
});

server.on('error', (err) => {
  console.error(`[Server] Server error: ${err.message}`);
});
