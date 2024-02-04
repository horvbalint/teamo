<script setup lang="ts">
import type { InUser } from '~/db';

const user = ref<InUser>({
  email: '',
  name: '',
  password: ''
})

const passwordAgain = ref('')
const isValid = ref(false)

const db = useSurreal()
async function signup() {
  try {
    const token = await db.value.signup({scope: 'user', ...user.value})
    storeAuthToken(token)

    navigateTo('/')
  }
  catch(err) {
    console.error(err)
    useNebToast({'type': 'error', title: 'Signup failed!', description: 'Try again later.'})
  }
}
</script>

<template>
  <div class="page-wrapper">
    <div class="form-wrapper">
      <h1>Login</h1>

      <div class="input-wrapper">
        <neb-validator v-model="isValid">
          <neb-input required v-model="user.name" label="Name" />
          <neb-input required v-model="user.email" label="Email" type="email" />
          <neb-input required v-model="user.password" label="Password" type="password"/>
          <neb-input required v-model="passwordAgain" label="Password again" type="password"/>
        </neb-validator>
      </div>

      <div class="button-wrapper">
        <neb-button type="link" @click="navigateTo('/login')">or login</neb-button>
        <neb-button :disabled="!isValid || user.password !== passwordAgain" @click="signup()">
          Signup
        </neb-button>
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
  gap: var(--space-8);
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