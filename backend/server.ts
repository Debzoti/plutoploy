import { Hono } from "hono";
import { cors } from "hono/cors";

const app = new Hono();

// Enable CORS
app.use("/*", cors());

// Test endpoint
app.get("/", (c) => {
  return c.json({
    message: "Deployment Platform API (Hono + Bun)",
    status: "running",
    runtime: "Bun",
  });
});

// Deploy endpoint (placeholder)
app.post("/deploy", (c) => {
  return c.json({ message: "Deploy endpoint - coming soon!" });
});

// Start server
const port = 3000;
console.log(`🚀 Server running on port ${port}`);

export default {
  port,
  fetch: app.fetch,
};
