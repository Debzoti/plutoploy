import { Hono } from "hono";
import { cors } from "hono/cors";
const app = new Hono();
// Enable CORS
app.use("/*", cors());

// Test endpoint
app.get("/index", (c) => {
  return c.json({
    message: "Deployment Platform API (Hono + Bun)",
    status: "running",
    runtime: "Bun",
  });
});

app.get("/health", (c) => {
  return c.json({ message: "Deployment online :)" });
});

// Deploy endpoint (placeholder)
app.post("/deploy", (c) => {
  return c.json({ message: "Deploy endpoint - coming soon!" });
});

const port = 3000;

export function startServer() {
  Bun.serve({
    port,
    fetch: app.fetch,
  });
  console.log(`🚀 Server running on port ${port}`);
}

export { app, port };
