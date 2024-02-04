import type { OutUser } from "~/db";

export default defineNuxtRouteMiddleware(async () => {
  const db = useSurreal();

  try {
    const token = getAuthToken()
    if(token)
      await db.value.authenticate(token)

    const result = await db.value.info<OutUser>()
    if (!result)
      throw new Error('Not authed!')

    useAuthUser().value = result
  }
  catch(err) {
    console.error(err)
    return navigateTo('/login')
  }
})