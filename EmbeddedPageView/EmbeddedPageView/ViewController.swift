//
//  ViewController.swift
//  EmbeddedPageView
//
//  Created by Don Mag on 8/21/23.
//

import UIKit

class ViewController: UIViewController {

	override func viewDidLoad() {
		super.viewDidLoad()
	}

	@IBAction func profileButtonTapped(_ sender: Any) {
		if let vc = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "ProfileViewController") as? ProfileViewController {
			navigationController?.pushViewController(vc, animated: true)
		}
	}

}

class ProfileViewController: UIViewController {
	
	@IBOutlet var stepsSegCtrl: UISegmentedControl!
	
	// we will want a reference to the embedded MainSegPageViewController
	//	so we can tell it to change page when the segmented control is tapped
	var mainSegPageVC: MainSegPageViewController?
	
	override func viewDidLoad() {
		super.viewDidLoad()
		self.title = "Pagination VC"
	}

	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		// this is called because we've embedded the controller in a container view
		if let pgVC = segue.destination as? MainSegPageViewController {
			// set the closure
			pgVC.pageChanged = { [weak self] pg in
				guard let self = self else { return }
				// user dragged to a new page, so update the segmented control
				self.stepsSegCtrl.selectedSegmentIndex = pg
			}
			// save reference so we can access it when the segmented control is tapped
			mainSegPageVC = pgVC
		}
	}
	
	@IBAction func segCtrlChanged(_ sender: UISegmentedControl) {
		// safely unwrap
		if let pgVC = mainSegPageVC {
			pgVC.gotoPage(pg: sender.selectedSegmentIndex)
		}
	}
	
}

class MainSegPageViewController: UIPageViewController {
	
	// closure to inform the parent controller that
	//	the user dragged to a new page
	var pageChanged: ((Int) -> ())?
	
	public func gotoPage(pg: Int) {
		let curPg = presentationIndex(for: self)
		if pg > curPg {
			setViewControllers([subViewcontrollers[pg]],
							   direction: .forward,
							   animated: true,
							   completion: nil)
		} else {
			setViewControllers([subViewcontrollers[pg]],
							   direction: .reverse,
							   animated: true,
							   completion: nil)
		}
	}
	
	private(set) lazy var subViewcontrollers: [UIViewController] = {
		return [
			UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "step1VC"),
			UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "step2VC"),
			UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "step3VC"),
		]
	}()
	
	override func viewDidLoad() {
		super.viewDidLoad()
		dataSource = self
		delegate = self
		
		if let firstViewController = subViewcontrollers.first {
			setViewControllers([firstViewController],
							   direction: .forward,
							   animated: true,
							   completion: nil)
		}
	}
	
}

// MARK: UIPageViewControllerDataSource
extension MainSegPageViewController: UIPageViewControllerDataSource, UIPageViewControllerDelegate {
	func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
		guard let viewControllerIndex = subViewcontrollers.firstIndex(of:viewController)
		else {
			return nil
		}
		let previousIndex = viewControllerIndex - 1
		guard previousIndex >= 0 else {
			return nil
		}
		guard subViewcontrollers.count > previousIndex else {
			return nil
		}
		if previousIndex == 2 {
			return nil
		}
		return subViewcontrollers[previousIndex]
	}
	
	func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
		guard let viewControllerIndex = subViewcontrollers.firstIndex(of:viewController)
		else {
			return nil
		}
		let nextIndex = viewControllerIndex + 1
		let orderedViewControllersCount = subViewcontrollers.count
		
		guard orderedViewControllersCount != nextIndex else {
			return nil
		}
		guard orderedViewControllersCount > nextIndex else {
			return nil
		}
		if nextIndex == 3 {
			return nil
		}
		return subViewcontrollers[nextIndex]
	}
	func presentationCount(for pageViewController: UIPageViewController) -> Int {
		return subViewcontrollers.count
	}
	func presentationIndex(for pageViewController: UIPageViewController) -> Int {
		guard let firstViewController = viewControllers?.first, let firstViewControllerIndex = subViewcontrollers.firstIndex(of: firstViewController) else {
			return 0
		}
		return firstViewControllerIndex
	}
	func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
		// user dragged to a new page, so inform the parent controller
		pageChanged?(presentationIndex(for: self))
	}
}

class Step1VC: UIViewController {
	
}
class Step2VC: UIViewController {
	
}
class Step3VC: UIViewController {
	
}
