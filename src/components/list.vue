<script setup lang="ts">
import type { InItem, OutItem } from '~/db';
import type { PreviewList } from '~/pages/list/index.vue';

const props = defineProps<{
  list: PreviewList
}>()

const db = useSurreal()
const items = ref<(OutItem | InItem)[]>([])
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
    list: props.list.id,
    name: '',
    tags: []
  })
}

function addIfLast(index: number) {
  if(index !== items.value.length-1)
    return

  add()
}

const pendingPromises = ref<Promise<unknown>[]>([])

function saveItem(index: number, item: InItem | OutItem) {
  if(!item.id)
    createItem(index, item as InItem)
  else
    updateItem(index, item as OutItem)
}

async function updateItem(index: number, item: OutItem) {
  try {
    const promise = db.value.merge(item.id, item)
    await runPromiseInSequence(promise)
  }
  catch(err) {
    console.error(err)
    useNebToast({type: 'error', title: 'Failed to update list item!', description: 'Try again later.'})
  }
}

async function createItem(index: number, item: InItem) {
  try {
    const promise = db.value.create('item', {
      ...item,
      previousItem: items.value[index-1]?.id
    })
    await runPromiseInSequence(promise)
  }
  catch(err) {
    console.error(err)
    useNebToast({type: 'error', title: 'Failed to create list item!', description: 'Try again later.'})
  }
}

// TODO: kitalalni, hogy ez a pending hogyan lesz jo (a promise itt mar akkor zajlik amikor megkapjuk mint parameter)

async function runPromiseInSequence<T extends unknown>(promise: Promise<T>): Promise<T> {
  if(pendingPromises.value.length)
    await pendingPromises.value[pendingPromises.value.length-1]

  pendingPromises.value.push(promise)
  const result = await promise
  pendingPromises.value.shift()

  return result as T
}

</script>

<template>
  <div class="list">
    <div class="header-row">
      <h1>{{ list.name }}</h1>

      <neb-button type="secondary-neutral" square>
        <icon name="material-symbols:edit-outline-rounded" />
      </neb-button>
    </div>

    <div class="items">
      <div class="item" v-for="(item, index) in items" :key="index">
        <neb-checkbox v-model="item.done" :disabled="!item.id"/>
  
        <neb-input
          v-model.lazy="item.name"
          auto-height
          @keyup.enter="addIfLast(index)"
          @change="saveItem(item, index)"
        >
          <template #trailing>
            <icon name="material-symbols:delete-outline-rounded" @click="items.splice(index, 1)"/>
          </template>
        </neb-input>
      </div>
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
  gap: var(--space-6);
}
.header-row {
  display: flex;
  justify-content: space-between;
  align-items: center;
}
.items {
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