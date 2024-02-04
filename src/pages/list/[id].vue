<script setup lang="ts">
import type { OutList } from '~/db'
import type { PreviewList } from './index.vue';

definePageMeta({
  middleware: 'auth'
})

const db = useSurreal()
const route = useRoute()

const list = ref<null | PreviewList>(null)
const loading = ref(true)
db.value.query<[PreviewList]>('SELECT * FROM ONLY $list', {
  list: route.params.id,
})
  .then(([result]) => {
    list.value = result
    loading.value = false
  })
  .catch(err => {
    console.error(err)
    useNebToast({type: 'error', title: 'Failed to load list!', description: 'Try again later.'})
  })
</script>

<template>
<div>
  <List v-if="!loading" :list="list!" />
</div>
</template>

<style scoped>
</style>