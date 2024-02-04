<script setup lang="ts">

const email = ref('')
const password = ref('')
const isValid = ref(false)

const db = useSurreal()
async function login() {
  try {
    const token = await db.value.signin({
      scope: 'user',
      email: email.value,
      password: password.value,
    })
    storeAuthToken(token)

    navigateTo('/list')
  }
  catch(err) {
    console.error(err)
    useNebToast({type: 'error', title: 'Login failed!', description: 'Try again later!'})
  }
}
</script>

<template>
  <div class="page-wrapper">
    <div class="form-wrapper">
      <h1>Login</h1>

      <div class="input-wrapper">
        <neb-validator v-model="isValid">
          <neb-input v-model="email" label="Email" type="email" />
          <neb-input v-model="password" label="Password" type="password"/>
        </neb-validator>
      </div>

      <div class="button-wrapper">
        <neb-button type="link" @click="navigateTo('/signup')">or signup</neb-button>
        <neb-button :disabled="!isValid" @click="login()">Login</neb-button>
      </div>
    </div>
  </div>
</template>

<style scoped>
.page-wrapper {
  width: 100%;
  height: 100%;
  display: flex;
  align-items: center;
  justify-content: center;
}
.form-wrapper {
  padding: var(--space-4);
  background: var(--neutral-color-100);
  border-radius: var(--radius-default);
  display: flex;
  flex-direction: column;
  gap: var(--space-6);
}
.input-wrapper {
  display: flex;
  flex-direction: column;
  gap: var(--space-3);
}

.button-wrapper {
  display: flex;
  flex-direction: column;
  gap: var(--space-2);
}
.dark-mode {
  .form-wrapper {
    background: var(--neutral-color-900);
  }
}
</style>