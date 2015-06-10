import UIKit

enum SecondaryPosition {
    case Unconfigured
    case Bottom
    case Top
}

class ViewController: UIViewController, UIScrollViewDelegate {
    let offsetToSwitch : CGFloat = 120
    let scrollHeights : Array<CGFloat> = [800, 1000, 1000, 2000, 700, 1000];
    var currentScrollViewIndex : Int = 0

    var primaryScroll : UIScrollView!
    var secondaryScroll : UIScrollView!

    var lastScrollY : CGFloat = 0
    var secondaryPosition : SecondaryPosition = .Unconfigured

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.yellowColor()

        self.primaryScroll = UIScrollView()
        self.primaryScroll.frame.size = self.view.frame.size
        self.view.addSubview(self.primaryScroll)

        self.secondaryScroll = UIScrollView()
        self.secondaryScroll.frame.size = self.view.frame.size
        self.view.addSubview(self.secondaryScroll)

        self.view.bringSubviewToFront(self.primaryScroll)
        self.setupScrollView(self.primaryScroll, index: self.currentScrollViewIndex)
        self.primaryScroll.delegate = self
    }

    func setupScrollView(scrollView: UIScrollView, index: Int) {
        scrollView.contentOffset = CGPointZero
        scrollView.contentSize = CGSizeMake(self.view.frame.width, self.scrollHeights[index])
        if index%2 == 0 {
            scrollView.backgroundColor = UIColor.orangeColor()
        } else {
            scrollView.backgroundColor = UIColor.redColor()
        }
    }

    func setupSecondaryScrollWithIndex(index: Int, position: SecondaryPosition) {
        self.setupScrollView(self.secondaryScroll, index: index)
        var frame = self.secondaryScroll.frame
        if position == .Top {
            frame.origin.y = self.view.frame.size.height
        } else if position == .Bottom {
            frame.origin.y = -self.view.frame.size.height
        }
        self.secondaryScroll.frame = frame
        self.secondaryPosition = position
        self.view.bringSubviewToFront(self.secondaryScroll)
    }

    func scrollViewDidScroll(scrollView: UIScrollView) {
        let offsetY = scrollView.contentOffset.y
        let remainingBottom = scrollView.contentSize.height - scrollView.frame.height - scrollView.contentOffset.y

        // configure secondary scrollView if reaching end
        if offsetY < self.lastScrollY && offsetY < 3 && self.currentScrollViewIndex > 0 && self.secondaryPosition != .Top {
            self.setupSecondaryScrollWithIndex(self.currentScrollViewIndex - 1, position: .Top)
        } else if offsetY > self.lastScrollY && remainingBottom < 3 && self.currentScrollViewIndex < self.scrollHeights.count - 1 && self.secondaryPosition != .Bottom {
            self.setupSecondaryScrollWithIndex(self.currentScrollViewIndex + 1, position: .Bottom)
        }

        // check if we need to move secondary scrollview, or switch to it
        // could be cleaner and merged with the code above
        if offsetY < 0 && self.currentScrollViewIndex > 0 {
            if offsetY < -offsetToSwitch {
                self.switchToSecondaryView()
            } else {
                self.secondaryScroll.frame.origin.y = -self.view.frame.height - offsetY
            }
        } else if remainingBottom < 0 && self.currentScrollViewIndex < self.scrollHeights.count - 1 {
            if remainingBottom < -offsetToSwitch {
                self.switchToSecondaryView()
            } else {
                self.secondaryScroll.frame.origin.y = self.view.frame.height + remainingBottom
            }
        }

        self.lastScrollY = scrollView.contentOffset.y
    }

    func switchToSecondaryView() {
        self.primaryScroll.userInteractionEnabled = false
        self.secondaryScroll.userInteractionEnabled = false

        self.primaryScroll.delegate = nil

        var primaryFrame = self.primaryScroll.frame

        if self.secondaryPosition == .Top {
            primaryFrame.origin.y = self.view.frame.size.height
            self.secondaryPosition = .Bottom
            self.currentScrollViewIndex -= 1
        } else if self.secondaryPosition == .Bottom {
            primaryFrame.origin.y = -self.view.frame.size.height
            self.secondaryPosition = .Top
            self.currentScrollViewIndex += 1
        }

        UIView.animateWithDuration(0.3,
            animations: { () -> Void in
                self.primaryScroll.frame = primaryFrame
                self.secondaryScroll.frame.origin.y = 0
            })
            { (finished : Bool) -> Void in
                swap(&self.primaryScroll, &self.secondaryScroll)
                self.view.bringSubviewToFront(self.secondaryScroll)
                self.primaryScroll.delegate = self
                self.primaryScroll.userInteractionEnabled = true
                self.secondaryScroll.userInteractionEnabled = true
            }
    }

}

