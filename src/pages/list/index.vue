<script setup lang="ts">
import type { OutItem, OutList } from '~/db';

export type PreviewList = OutList & {items: OutItem[]}

definePageMeta({
  middleware: 'auth'
})

const db = useSurreal()

const lists = ref<PreviewList[]>([])
const loading = ref(true)
db.value.query<[PreviewList[]]>('SELECT *, fn::getFirstThreeItems(id) as items FROM list', {
  user: useAuthUser().value
})
  .then(([result]) => {
    lists.value = result
    loading.value = false
  })
  .catch(err => {
    console.error(err)
    useNebToast({type: 'error', title: 'Failed to load lists!', description: 'Try again later.'})
  })

const newListModal = ref(false)
</script>

<template>
  <neb-loading-state v-if="loading" />
  <div v-else class="page-wrapper">
    <neb-content-header
      title="Your lists"
      description="Browse your saved lists, or create a new one!"
      :wrap="false"
    >
      <template #actions>
        <neb-button type="secondary" square @click="newListModal = true">
          <icon name="material-symbols:add-rounded" />
        </neb-button>
      </template>
    </neb-content-header>

    <div class="cards-wrapper">
      <list-card v-for="list in lists" :list="list"/>
    </div>

    <NewListModal v-model="newListModal" @create="navigateTo(`/list/${$event.id}`)" />
  </div>
</template>

<style scoped>
.page-wrapper {
  display: flex;
  flex-direction: column;
  gap: var(--space-8);
}
.cards-wrapper {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: var(--space-2);
}
</style>