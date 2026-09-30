import type { NextConfig } from "next";
import pkg from "./package.json" with { type: "json" };

const nextConfig: NextConfig = {
  reactCompiler: true,
  env: {
    NEXT_PUBLIC_APP_VERSION: pkg.version,
  },
  allowedDevOrigins: ["192.168.0.27"],
  output: "standalone",
};

export default nextConfig;
