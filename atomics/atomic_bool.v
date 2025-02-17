// Copyright (c) 2025 Marc E. Colosimo. All rights reserved.
// Use of this source code is governed by an MIT license
// that can be found in the LICENSE file
module atomics

import sync

pub struct AtomicBool {
mut:
	ptr		C.atomic_uintptr_t
	mutex	sync.RwMutex 			@[xdoc: 'write lock, for atomic store explicit']
}

pub fn new_atomic_bool(init_value bool) AtomicBool {
	mut m := sync.new_rwmutex() // might called init internally not such if all do
	//m.init()
	value := u16(if init_value { 1 } else { 0 }) // smallest atomic available
	
	mut a := AtomicBool {
		mutex: 	m
	}

	C.atomic_store_u16(&a.ptr, value)
	return a
}

@[inline]
pub fn (mut a AtomicBool) set(new_value bool) {
	a.mutex.lock()
	defer {
		a.mutex.unlock()
	}
	value := u16(if new_value { 1 } else { 0 })
	C.atomic_store_u16(&a.ptr, value)
}

@[inline]
pub fn (mut a AtomicBool) get() bool {
	a.mutex.rlock()
	defer {
		a.mutex.runlock()
	}
	return if C.atomic_load_u16(&a.ptr) == 0 { false } else { true }
}

// Atomically sets to the given value and returns the previous value. This Locks
@[inline]
pub fn (mut a AtomicBool) get_and_set(new_value bool) bool {
	a.mutex.lock()
	defer {
		a.mutex.unlock()
	}
	old_value := if C.atomic_load_u16(&a.ptr) == 1 { true } else { false }
	value := u16(if new_value { 1 } else { 0 })
	C.atomic_store_u16(&a.ptr, value)
	return old_value
}

@[inline]
pub fn (mut a AtomicBool) compare_and_set(expect bool, update bool) bool {
	a.mutex.lock()
	defer {
		a.mutex.unlock()
	}
	value := u16(if update { 1 } else { 0 })
	expect_value := u16(if expect { 1 } else { 0 })
	return C.atomic_compare_exchange_strong_u16(&a.ptr, &expect_value, value)
}

// Used to atomically compare and exchange values in a way that may fail spuriously.
// often used in lock-free data structure. This is lock-free!
@[inline]
pub fn (mut a AtomicBool) weak_compare_and_set(expect bool, update bool) bool {
	value := u16(if update { 1 } else { 0 })
	expect_value := u16(if expect { 1 } else { 0 })
	return C.atomic_compare_exchange_weak_u16(&a.ptr, &expect_value, value)
}
