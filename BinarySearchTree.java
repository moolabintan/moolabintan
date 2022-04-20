import java.util.ArrayList;
import java.util.Arrays;
import java.util.ConcurrentModificationException;
import java.util.Iterator;
import java.util.NoSuchElementException;
import java.util.Stack;

public class BinarySearchTree<T extends Comparable<? super T>> implements Iterable<T> {
	private BinaryNode root;
	private int size = 0;
	private int version = 0;

	public BinarySearchTree() {
		root = null;
	}

	
	public boolean isEmpty() {
		return root == null;
	}

	public BinaryNode getRoot() {
		return root;
	}

	public int height() {
		if (isEmpty()) {
			return -1;
		}
		return root.height();

	}

	public int size() {
		return size;

	}
	
	public void toArrayList(ArrayList<Object> l) {
		InOrderIterator i = new InOrderIterator(root);

		while (i.hasNext()) {
			l.add(i.next());
		}

	}

	public String toString() {
		if (isEmpty()) {
			return "[]";
		}
		return toArrayList().toString();
	}

	public ArrayList<Object> toArrayList() {
		if (isEmpty()) {
			return new ArrayList<Object>();
		}
		ArrayList<Object> list = new ArrayList<Object>();
		toArrayList(list);
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
			version++;
			return true;
		}  
			return root.insert(o);
		

	}

	
	public Iterator<T> iterator() {
		return new InOrderIterator(root);
	}

	public Iterator<T> preOrderIterator() {

		return new PreOrderIterator(root);
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
		}
		version++;
		return b.value;
	}

	public class BinaryNode {
		private T element;
		private BinaryNode leftChild;
		private BinaryNode rightChild;
		

		public BinaryNode(T element) {
			this.element = element;
			this.leftChild = null;
			this.rightChild = null;

		}

		public T getElement() {
			return element;
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

			int leftHeight = 0;
			int rightHeight = 0;
			int height = 0;

			if (this.leftChild != null) {
				leftHeight = this.leftChild.height() + 1;
			}

			if (this.rightChild != null) {
				rightHeight = this.rightChild.height() + 1;
			}

			if (leftHeight >= rightHeight) {
				height = leftHeight;
			} else {
				height = rightHeight;
			}

			return height;
		}


		public boolean insert(T o) {

			if (this.element.compareTo(o) > 0) {
				if (this.leftChild != null) {
					return this.leftChild.insert(o);
				}
				
				
				this.leftChild = new BinaryNode(o);
				size++;
				version++;
				return true;

			}
			if (this.element.compareTo(o) < 0) {
				if (this.rightChild != null) {
					return this.rightChild.insert(o);
				}
				
				this.rightChild = new BinaryNode(o);
				size++;
				version++;
				return true;
			}

			return false;

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
				}

			}

			if (comparison < 0) {
				if (this.rightChild != null) {
					this.rightChild = this.rightChild.remove(o, b);
				}

			}

			return this;
		}

	}

	public class InOrderIterator implements Iterator<T> {
		private Stack<BinaryNode> s = new Stack<BinaryNode>();
		BinaryNode n = null;
		private int myVersion = version;

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

		
		public boolean hasNext() {
			
			return !s.isEmpty();
		}

	
		public T next() {
			
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
				
				
				BinaryNode node = s.pop();
				n = node;
				return node.element;
			}

		}

		public void remove() {

			if (n == null) {
				throw new IllegalStateException();
			}
			
			if(myVersion != version) {
				throw new ConcurrentModificationException();
			}

			BinarySearchTree.this.remove(n.element);
			n = null;
			
			
			myVersion++;

		}

	}

	public class PreOrderIterator implements Iterator<T> {
		private Stack<BinaryNode> s = new Stack<BinaryNode>();
		BinaryNode n = null;
		private int myVersion = version;

		public PreOrderIterator(BinaryNode node) {
			if (node != null) {
				s.push(node);

			}

		}

		@Override
		public boolean hasNext() {
			
			return !s.empty();
		}

		@Override
		public T next() {

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
			
			if(myVersion != version) {
				throw new ConcurrentModificationException();
			}

			// Have i called next
			// have i not called remove
			BinarySearchTree.this.remove(n.element);
			if (n.leftChild != null && n.rightChild != null) {
				s.pop();
				s.pop();
				s.push(n);

			}
			n = null;
			
			
			

		}

	}

	private class MyBoolean {
		private boolean value = true;

		public void SetFalse() {
			value = false;
		}

	}

}
