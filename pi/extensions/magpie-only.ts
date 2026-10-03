import { getBuiltinProviders } from "@earendil-works/pi-ai/providers/all";
import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";

/** Keep shell credentials available to tools without offering direct LLM routes. */
export default function (pi: ExtensionAPI) {
  for (const provider of getBuiltinProviders()) {
    pi.registerProvider(provider, { models: [] });
  }

  // Also cover custom providers loaded from models.json or other extensions.
  pi.on("session_start", (_event, ctx) => {
    const providers = new Set(ctx.modelRegistry.getAll().map((model) => model.provider));
    for (const provider of providers) {
      if (provider !== "magpie") pi.registerProvider(provider, { models: [] });
    }
  });
}
