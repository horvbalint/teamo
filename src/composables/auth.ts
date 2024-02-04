import type { OutUser } from "~/db";

export function storeAuthToken(token: string) {
  localStorage.setItem('teamo_token', token)
}

export function getAuthToken() {
  return localStorage.getItem('teamo_token')
}

export function clearAuthToken() {
  localStorage.removeItem('teamo_token')
}

export function useAuthUser() {
  return useState<null | OutUser>('authUser', () => null)
}