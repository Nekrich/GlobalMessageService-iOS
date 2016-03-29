//
//  InboxViewController.swift
//  GlobalMessageService
//
//  Created by Vitalii Budnik on 2/25/16.
//  Copyright © 2016 Global Message Services Worldwide. All rights reserved.
//

import Foundation
import UIKit
import JSQMessagesViewController

/**
Shows delivered `GlobalMessageServiceMessage`s
*/
public class GlobalMessageServiceInboxViewController: JSQMessagesViewController {
  
  // swiftlint:disable line_length
  /// Message fetcher
  private let fetcher: GlobalMessageServiceMessageFetcherJSQ = GlobalMessageServiceMessageFetcherJSQ.sharedInstance
  // swiftlint:enable line_length
  
  public var isVisible: Bool {
    if isViewLoaded() {
      return view.window != nil
    }
    return false
  }
  
  public var isTopViewController: Bool {
    if let navigationController = navigationController {
      return navigationController.visibleViewController === self
    } else if let tabBarController = tabBarController {
      return tabBarController.selectedViewController == self && self.presentedViewController == nil
    } else {
      return self.presentedViewController == nil && self.isVisible
    }
  }
  
  /**
   The number of seconds between firings of the todays messages fetcher timer. If it is
   less than or equal to 30.0, sets the value of 30.0 seconds instead. (private)
   */
  private var _todaysMesagesUpdateInterval: NSTimeInterval = 60
  
  /// Auto-fetch delivered messages timer
  private weak var todaysMesagesUpdateTimer: NSTimer? = .None
  
  public func fetchTodaysMesagesTimerFired(sender: NSTimer) {
    fetchTodaysMesages()
  }
  
  public func fetchTodaysMesages(fetch: Bool = true) {
    stopTimer()
    fetcher.fetchTodaysMessages(fetch) { [weak self] newMessagesFetched in
      guard let sSelf = self else { return }
      if newMessagesFetched {
        sSelf.finishReceivingMessageAnimated(true)
      }
      if sSelf.isTopViewController == true {
        sSelf.startTimer()
      }
    }
  }
  
  /**
   The number of seconds between firings of the todays messages fetcher timer. If it is
   less than or equal to 30.0, sets the value of 30.0 seconds instead.
   Calculated variable
   */
  public var todaysMesagesUpdateInterval: NSTimeInterval {
    get {
      return _todaysMesagesUpdateInterval
    }
    set {
      _todaysMesagesUpdateInterval = max(newValue, 30)
      startTimer()
    }
  }
  
  // MARK: Lifecycle
  override public func viewDidLoad() {
    super.viewDidLoad()
    
    collectionView?.collectionViewLayout.messageBubbleLeftRightMargin = 58.0
    
    JSQMessagesCollectionViewCell.registerMenuAction(#selector(NSObject.delete(_:)))
    
    showLoadEarlierMessagesHeader = fetcher.hasMorePrevious
    
    fetcher.delegate = self
    
    JSQMessagesTimestampFormatter.sharedFormatter().dateFormatter.timeStyle = .NoStyle
    JSQMessagesTimestampFormatter.sharedFormatter().dateFormatter.dateStyle = .LongStyle
    
    senderId = "SenderID"
    senderDisplayName = "Sender display name"
    
    setupBubbles()
    
    setupBubbleTextColors()
    
    setupAvatars()
    
    loadPrevious()
    
    hideInputToolbar()
    
    fetchTodaysMesages(false)
    
  }
  
  /// Data source for `JSQMessagesCollectionView`
  var dataSource: [GlobalMessageServiceMessageJSQ] {
    get {
      return fetcher.messages
    }
  }
  
  /// Stops auto-fetch delivered messages timer
  private func stopTimer() {
    todaysMesagesUpdateTimer?.invalidate()
    todaysMesagesUpdateTimer = .None
  }
  
  /// Starts auto-fetch delivered messages timer
  private func startTimer() {
    stopTimer()
    todaysMesagesUpdateTimer = NSTimer.scheduledTimerWithTimeInterval(
      _todaysMesagesUpdateInterval,
      target: self,
      selector: #selector(fetchTodaysMesagesTimerFired(_:)),
      userInfo: .None,
      repeats: false)
  }
  
  public override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)
    
    fetchTodaysMesages()
    
  }
  
  public override func viewWillDisappear(animated: Bool) {
    super.viewWillDisappear(animated)
    stopTimer()
  }
  
  override public func willTransitionToTraitCollection(
    newCollection: UITraitCollection,
    withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) // swiftlint:disable:this line_length
  {
    coordinator.animateAlongsideTransition(.None) { [weak self] _ in
      self?.reloadViews()
    }
  }
  
  /// Redraws visible cells (Time label text update)
  private func reloadViews() {
    collectionView?.visibleCells().forEach { (cell) -> () in
      guard let indexPath = collectionView?.indexPathForCell(cell) else { return }
      let date = dataSource[indexPath.item].date()
      addTimeLabelToCell(cell, withDate: date)
    }
  }
  
  // MARK: Setup
  /// Setups avatar sizes
  private func setupAvatars() {
    collectionView?.collectionViewLayout.incomingAvatarViewSize = CGSize.zero
    collectionView?.collectionViewLayout.outgoingAvatarViewSize = CGSize.zero
  }
  
  public var smsBubbleImageView: JSQMessagesBubbleImage!
  public var viberBubbleImageView: JSQMessagesBubbleImage!
  public var pushBubbleImageView: JSQMessagesBubbleImage!
  
  public var smsBubbleTextColor: UIColor!
  public var viberBubbleTextColor: UIColor!
  public var pushBubbleTextColor: UIColor!
  
  /// Setups messages bubble colors for diffrent message types
  private func setupBubbles() {
    let factory = JSQMessagesBubbleImageFactory()
    smsBubbleImageView = factory.incomingMessagesBubbleImageWithColor(
      UIColor(red: 0.0/255.0, green: 195.0/255.0, blue: 82.0/255.0, alpha: 1))
    viberBubbleImageView = factory.incomingMessagesBubbleImageWithColor(
      UIColor(red: 124.0/255.0, green: 83.0/255.0, blue: 156.0/255.0, alpha: 1))
    pushBubbleImageView = factory.incomingMessagesBubbleImageWithColor(
      UIColor(red: 229.0/255.0, green: 229.0/255.0, blue: 234.0/255.0, alpha: 1))
  }
  
  /// Setups messages text colors for diffrent message types
  private func setupBubbleTextColors() {
    smsBubbleTextColor = UIColor.whiteColor()
    viberBubbleTextColor = UIColor.whiteColor()
    pushBubbleTextColor = UIColor.blackColor()
  }
  
  /// Loads messages for previous dates
  private func loadPrevious() {
    fetcher.loadPrevious { [weak self] in
      guard let sSelf = self else { return }
      sSelf.showLoadEarlierMessagesHeader = sSelf.fetcher.hasMorePrevious
      sSelf.automaticallyScrollsToMostRecentMessage = false
      sSelf.finishReceivingMessage()
    }
  }
  
  /**
   Returns `true` if day of current message is not equal to previous message date. `false` otherwise
   Actually returns `Bool` flag if we need to display header for bubble or not
   - Parameter indexPath:
   - Returns: `true` if day of current message is not equal to previous message date
   */
  private func previousMessageForIndexPathIsWithAnotherDate(indexPath: NSIndexPath) -> Bool {
    if indexPath.item == 0 {
      return true
    } else {
      let message = dataSource[indexPath.item]
      let previousMessage = dataSource[indexPath.item - 1]
      if previousMessage.date().startOfDay().timeIntervalSinceReferenceDate
        != message.date().startOfDay().timeIntervalSinceReferenceDate // swiftlint:disable:this opening_brace
      {
        return true
      }
    }
    return false
  }
  
  /// Time label tag const (right side of collection view cell)
  private let kTimeLabelTag = 1001

  /// Attributes for date label (bubble header)
  lazy private var dateFormatAttributes: [String: AnyObject] = {
    return [NSFontAttributeName: UIFont.boldSystemFontOfSize(12.0)]
  }()
  
  /// Attributes for alpha name label (bubble footer)
  lazy private var alphaNameFormatAttributes: [String: AnyObject] = {
    return [NSFontAttributeName: UIFont.systemFontOfSize(12.0)]
  }()
  
  /// `CGFloat` with alphaNameLabel (bubble footer) height
  lazy private var alphaNameLabelHeight: CGFloat = {
    let attr =  NSAttributedString(string: "qW", attributes: self.alphaNameFormatAttributes)
    let frame = attr.boundingRectWithSize(
      CGSize(width: 100, height: 20),
      options: [.UsesLineFragmentOrigin, .UsesFontLeading],
      context: .None)
    return frame.size.height
  }()
  
  /// `NSDateFormatter` for time label
  private lazy var timeFormatter: NSDateFormatter = {
    let formatter = NSDateFormatter()
    formatter.timeStyle = .ShortStyle
    formatter.dateStyle = .NoStyle
    return formatter
  }()
  
  /// `NSDateFormatter` for date label (bubble header)
  private lazy var dateFormatter: NSDateFormatter = {
    let formatter = NSDateFormatter()
    formatter.timeStyle = .NoStyle
    formatter.dateStyle = .LongStyle
    formatter.doesRelativeDateFormatting = true
    return formatter
  }()
  
  
  
}

// MARK: Multi-language support
public extension GlobalMessageServiceInboxViewController {
  
  public func setLanguage(localeIdentifier: String) {
    timeFormatter.locale = NSLocale(localeIdentifier: localeIdentifier)
    dateFormatter.locale = NSLocale(localeIdentifier: localeIdentifier)
    reloadViews()
    automaticallyScrollsToMostRecentMessage = true
    finishReceivingMessageAnimated(true)
  }
  
}

// MARK: - Hide input toolbar view
private extension GlobalMessageServiceInboxViewController {
  
  /** 
   Sets collection view insets. Overrides `super` private method
   - Parameter top: top inset
   - Parameter bottom: bottom inset
   */
  private func jsq_setCollectionViewInsetsTopValue(top: CGFloat, bottomValue bottom: CGFloat) {
    var insets = collectionView?.contentInset ?? UIEdgeInsetsZero
    insets.top = top
    insets.bottom = bottom
    //insets.bottom = 50
    collectionView?.contentInset = insets
    collectionView?.scrollIndicatorInsets = insets
  }
  
  /// Updates collection view insets. Overrides `super` private method
  private func jsq_updateCollectionViewInsets() {
    jsq_setCollectionViewInsetsTopValue(0, bottomValue: 0)
  }
  
  /// Hides input bar
  private func hideInputToolbar() {
    inputToolbar?.hidden = true
    jsq_updateCollectionViewInsets()
    inputToolbar?.removeFromSuperview()
  }
  
}

// MARK: - Collection View
// MARK: DataSource
public extension GlobalMessageServiceInboxViewController {
  
  override public func collectionView(
    collectionView: UICollectionView,
    cellForItemAtIndexPath indexPath: NSIndexPath)
    -> UICollectionViewCell // swiftlint:disable:this opening_brace
  {
    let cell = super.collectionView(collectionView, cellForItemAtIndexPath: indexPath)
    
    self.addTimeLabelToCell(cell, withDate: dataSource[indexPath.item].date())
    
    if let cell = cell as? JSQMessagesCollectionViewCell,
      let cellTextView = cell.textView // swiftlint:disable:this opening_brace
    {
      cellTextView.userInteractionEnabled = false
      let message = dataSource[indexPath.item]
      if message.type == .PushNotification {
        cellTextView.textColor = pushBubbleTextColor
      } else if message.type == .SMS {
        cellTextView.textColor = smsBubbleTextColor
      } else if message.type == .Viber {
        cellTextView.textColor = viberBubbleTextColor
      }
    }
    return cell
  }
  
  override public func collectionView(
    collectionView: JSQMessagesCollectionView!,
    messageDataForItemAtIndexPath indexPath: NSIndexPath!)
    -> JSQMessageData! // swiftlint:disable:this opening_brace
  {
    return dataSource[indexPath.item]
  }
  
  override public func collectionView(
    collectionView: UICollectionView,
    numberOfItemsInSection section: Int)
    -> Int // swiftlint:disable:this opening_brace
  {
    return dataSource.count
  }

}

// MARK: Delegate
public extension GlobalMessageServiceInboxViewController {
  
  override public func collectionView(
    collectionView: JSQMessagesCollectionView!,
    messageBubbleImageDataForItemAtIndexPath indexPath: NSIndexPath!)
    -> JSQMessageBubbleImageDataSource! // swiftlint:disable:this opening_brace
  {
    
    let message = dataSource[indexPath.item]
    
    switch message.type {
    case .PushNotification:
      return pushBubbleImageView
    case .SMS:
      return smsBubbleImageView
    case .Viber:
      return viberBubbleImageView
    }
    
  }
  
  override public func collectionView(
    collectionView: JSQMessagesCollectionView!,
    avatarImageDataForItemAtIndexPath indexPath: NSIndexPath!)
    -> JSQMessageAvatarImageDataSource! // swiftlint:disable:this opening_brace
  {
    return nil
  }
  
  public override func collectionView(
    collectionView: JSQMessagesCollectionView!,
    didDeleteMessageAtIndexPath indexPath: NSIndexPath!) // swiftlint:disable:this opening_brace
  {
    fetcher.delete(indexPath.item)
  }
}

// swiftlint:disable file_length

// MARK: Header
public extension GlobalMessageServiceInboxViewController {
  
  override public func collectionView(
    collectionView: JSQMessagesCollectionView!,
    header headerView: JSQMessagesLoadEarlierHeaderView!,
    didTapLoadEarlierMessagesButton sender: UIButton!) // swiftlint:disable:this opening_brace
  {
    loadPrevious()
  }
  
}

// MARK: Buble Header
public extension GlobalMessageServiceInboxViewController {
  
  override public func collectionView(
    collectionView: JSQMessagesCollectionView!,
    attributedTextForCellTopLabelAtIndexPath indexPath: NSIndexPath!)
    -> NSAttributedString! // swiftlint:disable:this opening_brace
  {
    let message = dataSource[indexPath.item]
    let messageDate: NSDate?
    if previousMessageForIndexPathIsWithAnotherDate(indexPath) {
      messageDate = message.date().startOfDay()
    } else {
      messageDate = .None
    }
    if let messageDate = messageDate {
      return NSAttributedString(
        string: dateFormatter.stringFromDate(messageDate),
        attributes: dateFormatAttributes)
    }
    return .None
  }
  
  override public func collectionView(
    collectionView: JSQMessagesCollectionView!,
    layout collectionViewLayout: JSQMessagesCollectionViewFlowLayout!,
    heightForCellTopLabelAtIndexPath indexPath: NSIndexPath!)
    -> CGFloat // swiftlint:disable:this opening_brace
  {
    if previousMessageForIndexPathIsWithAnotherDate(indexPath) {
      return kJSQMessagesCollectionViewCellLabelHeightDefault
    } else {
      return 0.0
    }
  }
  
}

// MARK: Buble Footer
public extension GlobalMessageServiceInboxViewController {
  
  public override func collectionView(
    collectionView: JSQMessagesCollectionView!,
    attributedTextForCellBottomLabelAtIndexPath indexPath: NSIndexPath!)
    -> NSAttributedString! // swiftlint:disable:this opening_brace
  {
    let message = dataSource[indexPath.item]
    let alphaNameAttributedString = NSAttributedString(
      string: message.alphaName + ". " + message.type.description,
      attributes: alphaNameFormatAttributes)
    return alphaNameAttributedString
  }
  
  public override func collectionView(
    collectionView: JSQMessagesCollectionView!,
    layout collectionViewLayout: JSQMessagesCollectionViewFlowLayout!,
    heightForCellBottomLabelAtIndexPath indexPath: NSIndexPath!)
    -> CGFloat // swiftlint:disable:this opening_brace
  {
    return alphaNameLabelHeight
  }
}

// MARK: Time Label
private extension GlobalMessageServiceInboxViewController {
  
  /**
   Returns configured time-`UILabel`
   - Returns: configured `UILabel`
   */
  private func timeLabel() -> UILabel {
    let timeLabel = UILabel()
    timeLabel.tag = kTimeLabelTag
    timeLabel.textColor = UIColor.grayColor()
    timeLabel.text = .None
    timeLabel.font = timeLabel.font.fontWithSize(11)
    timeLabel.textColor = UIColor.grayColor()
    return timeLabel
  }
  
  /**
   Adds time label to collection view cell
   - Parameter cell: `UICollectionViewCell` where to add time label
   - Parameter date: Time to display on label
   */
  private func addTimeLabelToCell(cell: UICollectionViewCell, withDate date: NSDate) {
    let timeLabel: UILabel
    if let existingLabel = cell.viewWithTag(kTimeLabelTag) as? UILabel {
      timeLabel = existingLabel
    } else {
      timeLabel = self.timeLabel()
      cell.addSubview(timeLabel)
    }
    timeLabel.text = timeFormatter.stringFromDate(date)
    
    let size = timeLabel.sizeThatFits(cell.frame.size)
    timeLabel.frame.size = size
    timeLabel.frame = CGRect(
      origin: CGPoint(
        x: cell.frame.size.width  - timeLabel.frame.size.width  - 8,
        y: cell.frame.size.height - timeLabel.frame.size.height - 2 - alphaNameLabelHeight),
      size: timeLabel.frame.size)
  }

}

extension GlobalMessageServiceInboxViewController: GlobalMessageServiceMessageFetcherJSQDelegate {
  /**
   Calls when new remote push-notification delivered
   */
  public func newMessagesFetched() {
    automaticallyScrollsToMostRecentMessage = true
    finishReceivingMessageAnimated(true)
  }
  
}

//extension GlobalMessageServiceInboxViewController: UISearchResultsUpdating {
//  
//  private func filterPresentedData(withText text: String?, 
// forScope scope: GlobalMessageServiceMessageType? = .None) {
//    
//    automaticallyScrollsToMostRecentMessage = true
//    
//    let searchText = text?.lowercaseString ?? ""
//    
//    let words = searchText.componentsSeparatedByString(" ").filter( { !$0.isEmpty })
//    
//    if ((searchText.isEmpty && scope == .None) || words.count == 0) 
// && (selectedSearchMessageType == .None) {
//      filteredMessages = fetcher.messages
//      collectionView.reloadData()
//      return
//    }
//    
//    filteredMessages = fetcher.messages.filter { message -> Bool in
//      var acceptable: Bool = words.count == 0
//      for searchText in words {
//        if message.alphaName.lowercaseString.containsString(searchText) {
//          acceptable = true
//        }
//        if let text = message.text() where text.lowercaseString.containsString(searchText) {
//          acceptable = true
//        }
//      }
//      if let scope = scope where acceptable {
//        acceptable = acceptable && message.type == scope
//      }
//      return acceptable
//    }
//    collectionView.reloadData()
//  }
//  
//  public func updateSearchResultsForSearchController(searchController: UISearchController) {
//    filterPresentedData(withText: searchController.searchBar.text, forScope: selectedSearchMessageType)
//  }
//  
//}
//
//extension GlobalMessageServiceInboxViewController: UISearchBarDelegate {
//  public func searchBar(searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
//    //let selectedCategory: PlaceCategory?
//    if selectedScope < 1 {
//      selectedSearchMessageType = .None
//    } else if (selectedScope - 1) < selectedSearchMessageTypes.count {
//      selectedSearchMessageType = selectedSearchMessageTypes[selectedScope - 1]
//    } else {
//      selectedSearchMessageType = .None
//    }
//    self.filterPresentedData(withText: searchController.searchBar.text, forScope: selectedSearchMessageType)
//  }
//}
