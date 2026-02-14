package com.mk.autosecure.libs.utils;


import androidx.annotation.NonNull;
import java.util.ArrayDeque;
import java.util.Collection;
import java.util.Iterator;
import java.util.Queue;

/**
 * Created by DoanVT on 2017/10/30.
 * Email: doanvt-hn@mk.com.vn
 */


public final class EvictingQueue<E> implements Collection<E> {

    private final Queue<E> delegate;

    final int maxSize;

    private EvictingQueue(int maxSize) {
        this.delegate = new ArrayDeque<E>(maxSize);
        this.maxSize = maxSize;
    }

    /**
     * Creates and returns a new evicting queue that will hold up to {@code maxSize} elements.
     *
     * <p>When {@code maxSize} is zero, elements will be evicted immediately after being added to the
     * queue.
     */
    public static <E> EvictingQueue<E> create(int maxSize) {
        return new EvictingQueue<E>(maxSize);
    }

    /**
     * Returns the number of additional elements that this queue can accept without evicting;
     * zero if the queue is currently full.
     *
     * @since 16.0
     */
    public int remainingCapacity() {
        return maxSize - size();
    }

    protected Queue<E> delegate() {
        return delegate;
    }

    /**
     * Adds the given element to this queue. If the queue is currently full, the element at the head
     * of the queue is evicted to make room.
     *
     * @return {@code true} always
     */
    public boolean offer(E e) {
        return add(e);
    }

    /**
     * Adds the given element to this queue. If the queue is currently full, the element at the head
     * of the queue is evicted to make room.
     *
     * @return {@code true} always
     */

    public boolean add(E e) {
        if (maxSize == 0) {
            return true;
        }
        if (size() == maxSize) {
            delegate.remove();
        }
        delegate.add(e);
        return true;
    }

    @Override
    public boolean addAll(@NonNull Collection<? extends E> collection) {
        boolean result = false;
        for (E item : collection) {
            result |= add(item);
        }
        return result;
    }

    @Override
    public boolean removeAll(Collection<?> c) {
        return delegate().removeAll(c);
    }

    @Override
    public boolean retainAll(Collection<?> c) {
        return delegate().retainAll(c);
    }

    @Override
    public void clear() {
        delegate().clear();
    }


    @Override
    public int size() {
        return delegate().size();
    }

    @Override
    public boolean isEmpty() {
        return false;
    }

    @Override
    public boolean contains(Object object) {
        return delegate().contains(object);
    }

    @Override
    public Iterator<E> iterator() {
        return delegate().iterator();
    }

    @Override
    public Object[] toArray() {
        return delegate().toArray();
    }

    @Override
    public <T> T[] toArray(T[] array) {
        return delegate().toArray(array);
    }

    @Override
    public boolean remove(Object object) {
        return delegate().remove(object);
    }

    @Override
    public boolean containsAll(Collection<?> c) {
        return false;
    }

    // TODO(kak): Do we want to checkNotNull each element in containsAll, removeAll, and retainAll?

    private static final long serialVersionUID = 0L;
}