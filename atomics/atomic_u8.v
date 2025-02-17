// Copyright (c) 2025 Marc E. Colosimo. All rights reserved.
// Use of this source code is governed by an MIT license
// that can be found in the LICENSE file
module atomics

import sync

pub struct AtomicU8 {
mut:
	ptr		C.atomic_uintptr_t
	mutex	sync.RwMutex 			@[xdoc: 'write lock, for atomic store explicit']

}

pub fn new_atomic_u8(init_value u8) AtomicU8 {
	mut m := sync.new_rwmutex() // might called init internally not such if all do
	//m.init()
	mut a := AtomicU8 {
		mutex: m
	}
	C.atomic_store_u16(&a.ptr, u16(init_value))
	return a
}

// Unconditionally sets to the given value. This locks.
@[inline]
pub fn (mut a AtomicU8) set(new_value u8) {
	a.mutex.lock()
	defer {
		a.mutex.unlock()
	}
	value := u16(new_value)
	C.atomic_store_u16(&a.ptr, value)
}

@[inline]
pub fn (mut a AtomicU8) get() u8 {
	a.mutex.rlock()
	defer {
		a.mutex.runlock()
	}
	return u8(C.atomic_load_u16(&a.ptr))
}

// Atomically sets to the given value and returns the previous value. This Locks
@[inline]
pub fn (mut a AtomicU8) get_and_set(new_value u8) u8 {
	a.mutex.lock()
	defer {
		a.mutex.unlock()
	}
	old_value := u8(C.atomic_load_u16(&a.ptr))
	value := u16(new_value)
	C.atomic_store_u16(&a.ptr, value)
	return old_value
}

// compare_and_set Atomically sets the value to the given updated value if the current value == the expected value.
@[inline]
pub fn (mut a AtomicU8) compare_and_set(expect u8, update u8) bool {
	a.mutex.lock()
	defer {
		a.mutex.unlock()
	}
	new_value := u16(update)
	expect_value := u16(expect)
	return C.atomic_compare_exchange_strong_u16(&a.ptr, &expect_value, new_value)
}

// weak_compare_and_set Used to atomically compare and exchange values in a way that may fail spuriously.
// often used in lock-free data structure.
@[inline]
pub fn (mut a AtomicU8) weak_compare_and_set(expect u8, update u8) bool {
	a.mutex.lock()
	defer {
		a.mutex.unlock()
	}
	new_value := u16(update)
	expect_value := u16(expect)
	return C.atomic_compare_exchange_strong_u16(&a.ptr, &expect_value, new_value)
}