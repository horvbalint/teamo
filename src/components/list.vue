<script setup lang="ts">
import type { OutItem } from '~/db';
import type { PreviewList } from '~/pages/list/index.vue';

const props = defineProps<{
  list: PreviewList
}>()

const db = useSurreal()
const items = ref<OutItem[]>([])
const loading = ref(false)

db.value.query<[OutItem[]]>(`SELECT * FROM item WHERE list = $list`, {
  list: props.list.id
})
  .then(([result]) => {
    const itemsEntries = result.map(i => [i.previousItem, i])
    const itemDict = Object.fromEntries(itemsEntries)

    const array: OutItem[] = []
    for(let i=0; i<result.length; ++i) {
      const lastId = array[array.length-1]?.id
      array.push(itemDict[lastId])
    }

    items.value = array
    loading.value = false
  })
  .catch(err => {
    console.error(err)
    useNebToast({type: 'error', title: 'Failed to load list items!', description: 'Try again later.'})
  })

function add() {
  items.value.push({
    id: '',
    list: '',
    name: '',
    tags: []
  })
}

function addIfLast(index: number) {
  if(index !== items.value.length-1)
    return

  add()
}
</script>

<template>
  <div class="list">
    <div class="item" v-for="(item, index) in items" :key="index">
      <neb-checkbox v-model="item.done"/>

      <neb-input v-model="item.name" auto-height @keyup.enter="addIfLast(index)">
        <template #trailing>
          <icon name="material-symbols:delete-outline-rounded" @click="items.splice(index, 1)"/>
        </template>
      </neb-input>
    </div>

    <neb-button class="add-button" @click="add()" square>
      <icon name="material-symbols:add-rounded"/>
    </neb-button>
  </div>
</template>

<style scoped>
.list {
  display: flex;
  flex-direction: column;
  gap: var(--space-2);
}
.item {
  display: flex;
  gap: var(--space-2);
}
.add-button {
  align-self: center;
}
</style>