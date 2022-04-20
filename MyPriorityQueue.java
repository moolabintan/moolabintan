import java.util.ArrayList;

public class MyPriorityQueue<T extends Comparable<? super T>> extends ArrayList<T> {

	public MyPriorityQueue() {
	}

	public boolean add(T e) {
		if (e == null) {
			throw new NullPointerException();
		}

		super.add(e);
		goUp();
		return true;
	}

	public boolean offer(T o) {

		return add(o);
	}

	public T peek() {
		if (isEmpty()) {
			return null;
		}
		return get(0);
	}

	public boolean remove(T o) {
		if (o == null) {
			throw new NullPointerException();
		}

		if (contains(o) == false) {
			return false;
		}

		int removeIndex = indexOf(o);

		T temp = get(size() - 1);
		super.set(removeIndex, temp);
//		super.set(size() - 1, o);

		super.remove(size() - 1);
		goDown(removeIndex);

		return true;
	}

	public T poll() {
		if (isEmpty()) {
			return null;
		}

		T temp = get(0);
		this.remove(temp);
		return temp;
	}

	public void goUp() {

		int index = size() - 1;
		while (index > 0) {
			int parentIndex = (index - 1) / 2;
			if (get(index).compareTo(get(parentIndex)) < 0) {
				T temp1 = get(parentIndex);
				super.set(parentIndex, get(index));
				super.set(index, temp1);

			}

			index = (index - 1) / 2;

		}

	}

	public void goDown(int index) {
		if (index < size()) {
			if (2 * index + 2 < size()) {
				T temp1 = null;
				if (get(2 * index + 1).compareTo(get(2 * index + 2)) < 0) {
					if (get(index).compareTo(get((2 * index) + 1)) > 0) {
						temp1 = get(2 * index + 1);
						super.set(2 * index + 1, get(index));
						super.set(index, temp1);
						goDown(2 * index + 1);
					}

				} else {
					if (get(index).compareTo(get((2 * index) + 2)) > 0) {
						temp1 = get(2 * index + 2);
						super.set(2 * index + 2, get(index));
						super.set(index, temp1);
						goDown(2 * index + 2);
					}
				}

			} else if (2 * index + 1 < size()) {
				T temp1 = null;

				if (get(index).compareTo(get((2 * index) + 1)) > 0) {
					temp1 = get(2 * index + 1);
					super.set(2 * index + 1, get(index));
					super.set(index, temp1);
					goDown(2 * index + 1);
				}
			}

		}

	}

}
