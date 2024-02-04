<script setup lang="ts">
import type { InList, OutList } from '~/db';

const emit = defineEmits<{
  create: [list: OutList],
}>()

const modelValue = defineModel()

const newList = ref<Partial<InList>>({
  name: '',
  color: '#ffffff',
  checklist: false,
  advanced: false,
})

const isValid = ref(false)
const db = useSurreal()
async function create() {
  try {
    const [list] = await db.value.create<OutList, Partial<InList>>('list', newList.value)
    emit('create', list)
  }
  catch(err) {
    console.error(err)
    useNebToast({type: 'error', 'title': 'Failed to create new list!', description: 'Try again later.'})
  }
}
</script>

<template>
  <neb-modal v-model="modelValue" title="Create new list" header-icon="material-symbols:format-list-bulleted">
    <template #content>
      <neb-validator v-model="isValid">
        <neb-input label="Name" v-model="newList.name" required />
        <neb-input label="Color" v-model="newList.color" type="color" />
        <neb-checkbox label="Checklist" v-model="newList.checklist" />
        <neb-checkbox label="Advanced" v-model="newList.advanced" />
      </neb-validator>
    </template>

    <template #actions>
      <neb-button :disabled="!isValid" @click="create()">Create</neb-button>
    </template>
  </neb-modal>
</template>

<style scoped>
</style>