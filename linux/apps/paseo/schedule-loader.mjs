import { patchScheduleSource } from './schedule-patch.mjs';
const target = '/node_modules/@getpaseo/server/dist/server/server/schedule/service.js';
export async function load(url, context, nextLoad) {
  const result = await nextLoad(url, context);
  if (new URL(url).pathname.endsWith(target) && result.format === 'module') {
    return { ...result, source: patchScheduleSource(String(result.source)) };
  }
  return result;
}
