import Surreal from "surrealdb.js"

export function useSurreal() {
  return useState('surreal', () => new Surreal())
}
