import { test, expect } from '@playwright/test'

test('login screen loads', async ({ page }) => {
  await page.goto('/login')
  await expect(page.getByText('Entrar com Keycloak')).toBeVisible()
})
