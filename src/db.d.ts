export type InItem = {
	assignee?: Required<InUser>['id']
	date?: Date | string
	description?: string
	done?: boolean
	id?: string
	list: Required<InList>['id']
	name: string
	previousItem?: Required<InItem>['id']
	tags: Array<Required<InTag>['id']>
}

export type OutItem = {
	assignee?: OutUser['id'] | OutUser
	date?: string
	description?: string
	done?: boolean
	id: string
	list: OutList['id'] | OutList
	name: string
	previousItem?: OutItem['id'] | OutItem
	tags: Array<OutTag['id'] | OutTag>
}

export type InList = {
	advanced: boolean
	archived?: boolean
	checklist: boolean
	color: string
	creator?: Required<InUser>['id']
	id?: string
	lastModified?: Date | string
	name: string
	sharedWith?: Array<Required<InUser>['id']>
	timelineResolution?: string
	view?: string
}

export type OutList = {
	advanced: boolean
	archived?: boolean
	checklist: boolean
	color: string
	creator?: OutUser['id'] | OutUser
	id: string
	lastModified?: string
	name: string
	sharedWith?: Array<OutUser['id'] | OutUser>
	timelineResolution?: string
	view?: string
}

export type InTag = {
	color: string
	id?: string
	list: Required<InList>['id']
	name: string
}

export type OutTag = {
	color: string
	id: string
	list: OutList['id'] | OutList
	name: string
}

export type InUser = {
	email: string
	id?: string
	name: string
	password: string
}

export type OutUser = {
	email: string
	id: string
	name: string
	password: string
}

