<script setup lang="ts">
import type { PreviewList } from '~/pages/list/index.vue';

defineProps<{
  list: PreviewList
}>()
</script>

<template>
  <div class="list-card" @click="navigateTo(`/list/${$props.list.id}`)">
    <div class="content-wrapper">
      <h3>{{$props.list.name}}</h3>

      <div class="items-wrapper">
        <p v-for="item in $props.list.items">
          {{item.name}}
        </p>
      </div>
    </div>
  </div>
</template>

<style scoped>
.list-card {
  border-radius: var(--radius-default);
  padding-top: var(--space-2);
  background: v-bind('$props.list.color');
}
.content-wrapper {
  height: 100%;
  padding: var(--space-2) var(--space-3);
  background: rgba(var(--neutral-color-component-50), 0.9);
  display: flex;
  flex-direction: column;
  gap: var(--space-2);
}
.items-wrapper {
  display: flex;
  flex-direction: column;
  gap: 2px;

  p {
    color: var(--neutral-color-700);
  }
}
.dark-mode {
  .content-wrapper {
    background: rgba(var(--neutral-color-component-950), 0.9);

    h3 {
      color: var(--neutral-color-200);
    }
  }
  .items-wrapper {
    p {
      color: var(--neutral-color-300);
    }
  }
}
</style>