// Export every table from the WHO/ILO Occupational Burden of Disease application.
//
// The WHO/ILO Joint Estimates are published only through an interactive web application
// (https://who-ilo-joint-estimates.shinyapps.io/OccupationalBurdenOfDisease/). Its "Data" tab
// has an "Export" button that downloads one CSV file per risk factor. This script opens the
// application in a headless browser and clicks through every option on that tab.
//
// Requirements: Node.js and the Playwright package with a Chromium browser
//   npm install playwright && npx playwright install chromium
//
// Usage:  node scripts/export_from_app.js data/raw
//
// About 1 GB is downloaded (the occupational injuries file alone is about 400 MB) and it takes
// 30 to 60 minutes. Files already present are skipped, so it can be rerun after an interruption.

const { chromium } = require('playwright');
const fs = require('fs');

const APP = 'https://who-ilo-joint-estimates.shinyapps.io/OccupationalBurdenOfDisease/';
const out = process.argv[2] || 'data/raw';
fs.mkdirSync(out, { recursive: true });

// Wait until the Shiny server has finished recalculating
async function idle(page) {
  await page.waitForTimeout(1500);
  await page.waitForFunction(() => !document.documentElement.classList.contains('shiny-busy'),
    null, { timeout: 300000 });
  await page.waitForTimeout(1500);
}

// The drop-downs are bootstrap-select widgets: set the underlying <select> and notify Shiny
async function setSelect(page, id, value) {
  await page.evaluate(([id, value]) => {
    const $s = window.jQuery('#' + id);
    $s.val(value);
    if ($s.selectpicker) $s.selectpicker('refresh');
    $s.trigger('change');
  }, [id, value]);
  await idle(page);
}

async function options(page, id) {
  return page.evaluate(id => Array.from(document.getElementById(id).options).map(o => o.value), id);
}

async function exportTo(page, file) {
  if (fs.existsSync(file)) {
    console.log('Already have', file);
    return;
  }
  await page.evaluate(() => document.getElementById('cmd_data_refresh').click());
  await idle(page);
  await page.waitForFunction(
    () => (document.querySelector('#cmd_export_data').getAttribute('href') || '').includes('download'),
    null, { timeout: 180000 });
  const [download] = await Promise.all([
    page.waitForEvent('download', { timeout: 600000 }),
    page.evaluate(() => document.getElementById('cmd_export_data').click()),
  ]);
  await download.saveAs(file);
  console.log('saved', file, fs.statSync(file).size);
}

(async () => {
  const browser = await chromium.launch();
  const page = await browser.newPage({ acceptDownloads: true });
  await page.goto(APP, { timeout: 120000 });
  await page.waitForSelector('#cmd_data_refresh', { state: 'attached', timeout: 120000 });
  await idle(page);
  await page.getByRole('link', { name: 'Data', exact: true }).click();
  await idle(page);

  // Type (Estimate or Indicator) > Result (Burden of Disease, Exposure, ...) > Risk factor
  for (const type of await options(page, 'slc_data_type')) {
    await setSelect(page, 'slc_data_type', type);
    for (const result of await options(page, 'slc_data_result')) {
      await setSelect(page, 'slc_data_result', result);
      for (const risk of await options(page, 'slc_data_risk')) {
        await setSelect(page, 'slc_data_risk', risk);
        const name = [type, result, risk].join('__').replace(/[^A-Za-z0-9]+/g, '_');
        try {
          await exportTo(page, `${out}/${name}.csv`);
        } catch (e) {
          console.log('FAILED', name, e.message.split('\n')[0]);
        }
      }
    }
  }
  await browser.close();
})();
