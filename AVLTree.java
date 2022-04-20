import java.util.ArrayList;

import java.util.Arrays;
import java.util.Iterator;
import java.util.NoSuchElementException;
import java.util.Stack;

public class AVLTree<T extends Comparable<? super T>> implements Iterable<T> {
	BinaryNode root;
	private int size = 0;
	private int version = 1;
	private int rotationCount = 0;

	public AVLTree() {
		root = null;
	}

	public BinaryNode getRoot() {
		return root;
	}
	public int getRotationCount() {
		return rotationCount;
	}

	public boolean isEmpty() {
		return root == null;
	}

	public int height() {
		if (root == null) {
			return -1;
		}
		return root.height();

	}

	public int size() {

		return size;

	}

	public String toString() {

		return Arrays.toString(toArray());
	}

	public ArrayList<T> toArrayList() {

		ArrayList<T> list = new ArrayList<T>();
		root.toArrayList(list);
		return list;

	}

	public Object[] toArray() {
		return toArrayList().toArray();
	}

	public boolean insert(T o) {
		if (o == null) {
			throw new IllegalArgumentException();
		}

		if (root == null) {
			root = new BinaryNode(o);
			size++;
			return true;
		}

		MyBoolean b = new MyBoolean();
		root = root.insert(o, b);

		return b.value;

	}


	public Iterator<T> iterator() {
		return new PreOrderIterator(root);
	}

	public Iterator<T> inOrderIterator() {
		return new InOrderIterator(root);

	}

	public boolean remove(T o) {
		MyBoolean b = new MyBoolean();
		if (o == null) {
			throw new IllegalArgumentException();
		}

		if (isEmpty()) {
			return false;
		}

		b.SetFalse();
		root = root.remove(o, b);
		if (b.value) {
			size--;
			version++;
		}
		return b.value;
	}

	private class MyBoolean {
		private boolean value = true;

		public void SetFalse() {
			value = false;
		}

	}

	public class BinaryNode {
		T element;
		BinaryNode leftChild;
		BinaryNode rightChild;
		private int height;

		public BinaryNode(T element) {
			this.element = element;
			this.leftChild = null;
			this.rightChild = null;
			this.height = 0;

		}

		public T getElement() {
			return element;
		}
		
		public int getHeight() {
			return height;
		}

		public BinaryNode getLeftChild() {
			return leftChild;
		}

		public BinaryNode getRightChild() {
			return rightChild;
		}

		public int height() {
			if (this.leftChild == null && this.rightChild == null) {
				return 0;
			}

			return this.height;
		}

		public String toString() {
			String s = "";
			InOrderIterator i = new InOrderIterator(this);

			while (i.hasNext()) {
				s += i.toString();
			}

			return s;
		}

		public void toArrayList(ArrayList<T> l) {
			InOrderIterator i = new InOrderIterator(this);

			while (i.hasNext()) {
				l.add(i.next());
			}

		}

		public BinaryNode insert(T o, MyBoolean b) {
			int comparisson = this.element.compareTo(o);

			if (comparisson > 0) {
				if (this.leftChild != null) {
					this.leftChild = this.leftChild.insert(o, b);
					updateHeight();
					if (checkBalance()) {
						return balance();
					}

					return this;
				}

				this.leftChild = new BinaryNode(o);
				updateHeight();
				size++;
				version++;
				return this;
			}

			if (comparisson < 0) {
				if (this.rightChild != null) {
					this.rightChild = this.rightChild.insert(o, b);
					updateHeight();
					if (checkBalance()) {
						return balance();
					}
					return this;
				}
				this.rightChild = new BinaryNode(o);
				updateHeight();
				size++;
				version++;
				return this;

			}
			return this;

		}

		public void updateHeight() {
			int lHeight = -1;
			int rHeight = -1;
			if (this.leftChild != null) {
				lHeight = this.leftChild.height;
			}
			if (this.rightChild != null) {
				rHeight = this.rightChild.height;
			}
			if (lHeight > rHeight) {
				this.height = lHeight + 1;
			} else {
				this.height = rHeight + 1;
			}
		}

		public boolean checkBalance() {
			int leftHeight = -1;
			int rightHeight = -1;
			if (leftChild != null) leftHeight = leftChild.height;
			if (rightChild != null) rightHeight = rightChild.height;	
			return (Math.abs(rightHeight - leftHeight)>1);
		}

		public BinaryNode balance() {
			int leftHeight = -1;
			int rightHeight = -1;
			if (leftChild != null) leftHeight = leftChild.height;
			if (rightChild != null) rightHeight = rightChild.height;	
			
			if (leftHeight > rightHeight) {
				BinaryNode temp = leftChild;
				leftHeight = -1;
				rightHeight = -1;
				if (temp.leftChild != null) leftHeight = temp.leftChild.height;
				if (temp.rightChild != null) rightHeight = temp.rightChild.height;	
				if (leftHeight >= rightHeight) {	
					return rotateRight();
				}
				return doubleRotateRight();
			}
			
			BinaryNode temp = rightChild;
			leftHeight = -1;
			rightHeight = -1;
			if (temp.leftChild != null) leftHeight = temp.leftChild.height;
			if (temp.rightChild != null) rightHeight = temp.rightChild.height;	
			if (rightHeight >= leftHeight) {	
				return rotateLeft();
			}
			return doubleRotateLeft();




		}

		public BinaryNode rotateRight() {

			BinaryNode newRoot = this.leftChild;
			this.leftChild = newRoot.rightChild;

			newRoot.rightChild = this;

			updateHeight();
			newRoot.updateHeight();
			rotationCount++;

			return newRoot;
		}

		public BinaryNode rotateLeft() {
			BinaryNode newRoot = this.rightChild;
			this.rightChild = newRoot.leftChild;

			newRoot.leftChild = this;

			updateHeight();
			newRoot.updateHeight();

			rotationCount++;
			return newRoot;

		}

		public BinaryNode doubleRotateRight() {

			BinaryNode newRoot = this;
			newRoot.leftChild = newRoot.leftChild.rotateLeft();
			return newRoot.rotateRight();

		}

		public BinaryNode doubleRotateLeft() {

			BinaryNode newRoot = this;
			newRoot.rightChild = newRoot.rightChild.rotateRight();
			return newRoot.rotateLeft();

		}

		public BinaryNode remove(T o, MyBoolean b) {

			int comparison = this.element.compareTo(o);

			if (comparison == 0) {
				b.value = true;
				if (this.leftChild != null && this.rightChild != null) {
					BinaryNode cNode = this.leftChild;

					while (cNode.rightChild != null) {
						cNode = cNode.rightChild;
					}
					this.element = cNode.element;
					this.leftChild = this.leftChild.remove(cNode.element, b);

					if (checkBalance()) {

						return balance();
					}
					updateHeight();
					return this;

				}
				if (this.leftChild != null && this.rightChild == null) {
					return this.leftChild;
				}
				if (this.rightChild != null && this.leftChild == null) {
					return this.rightChild;
				}

				return null;
			}

			if (comparison > 0) {
				if (this.leftChild != null) {
					this.leftChild = this.leftChild.remove(o, b);

					if (checkBalance()) {

						return balance();
					}
					updateHeight();
					return this;
				}

			}


				if (this.rightChild != null) {
					this.rightChild = this.rightChild.remove(o, b);
				}
					if (checkBalance()) {

						return balance();
					}
					updateHeight();
					return this;
				

			

		}

	}

	public class InOrderIterator implements Iterator<T> {
		private Stack<BinaryNode> s = new Stack<BinaryNode>();
		BinaryNode n = null;

		public InOrderIterator(BinaryNode node) {
			if (node != null) {
				s.push(node);
				goLeft();
			}
		}

		public void goLeft() {
			while (s.peek().leftChild != null) {
				s.push(s.peek().leftChild);
			}

		}

		@Override
		public boolean hasNext() {
			// TODO Auto-generated method stub
			return !s.isEmpty();
		}

		@Override
		public T next() {
			// TODO Auto-generated method stub
			if (s.isEmpty()) {
				throw new NoSuchElementException();
			}

			if (s.peek().rightChild != null) {
				BinaryNode node = s.pop();
				n = node;
				s.push(node.rightChild);
				goLeft();
				return node.element;
			} else {
				return s.pop().element;
			}

		}

		public void remove() {

			if (n == null) {
				throw new IllegalStateException();
			}

			AVLTree.this.remove(n.element);
			n = null;

		}

	}

	public class PreOrderIterator implements Iterator<T> {
		private Stack<BinaryNode> s = new Stack<BinaryNode>();
		BinaryNode n = null;

		public PreOrderIterator(BinaryNode node) {
			int myVersion = version;
			if (node != null) {
				s.push(node);

			}

		}

		public boolean hasNext() {
			// TODO Auto-generated method stub
			return !s.empty();
		}


		public T next() {
			// TODO Auto-generated method stub
			if (s.isEmpty()) {
				throw new NoSuchElementException();
			}

			BinaryNode node = s.pop();
			n = node;
			if (node.rightChild != null) {
				s.push(node.rightChild);
			}
			if (node.leftChild != null) {
				s.push(node.leftChild);
			}

			return node.element;
		}

		public void remove() {
			// if my version num diff to global version num throw concmodexception
			// if i have two children, pop twice and push current node

			if (n == null) {
				throw new IllegalStateException();
			}

			// Have i called next
			// have i not called remove
			if (n.leftChild != null && n.rightChild != null) {
				s.push(n.rightChild);
				s.push(n.leftChild);
				AVLTree.this.remove(n.element);

			} else {
				AVLTree.this.remove(n.element);

			}
			n = null;

		}

	}

}
