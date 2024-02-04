export default defineNuxtRouteMiddleware(async () => {
  const db = useSurreal()

  try {
    await db.value.wait()
  }
  catch (err) {
    await db.value.connect('http://localhost:8000/rpc', {
      namespace: 'teamo',
      database: 'teamo',
    })
  }
})
