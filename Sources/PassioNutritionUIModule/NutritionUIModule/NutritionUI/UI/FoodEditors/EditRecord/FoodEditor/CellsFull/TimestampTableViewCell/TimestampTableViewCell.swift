//
//  TimestampTableViewCell.swift
//  Charts
//
//  Created by Patrick Goley on 5/4/21.
//

import UIKit

protocol TimestampCellDelegate: AnyObject {
    func didTapTimestampButton()
}

final class TimestampTableViewCell: UITableViewCell {

    @IBOutlet weak var timeStampLabel: UILabel!
    @IBOutlet weak var timestampButton: UIButton!
    @IBOutlet weak var insetBackgroundView: UIView!
    @IBOutlet weak var trailingButton: NSLayoutConstraint!
    @IBOutlet weak var leadingButton: NSLayoutConstraint!
    @IBOutlet weak var leadingTimeStampLabel: NSLayoutConstraint!

    override func awakeFromNib() {
        super.awakeFromNib()
        insetBackgroundView.roundMyCornerWith(radius: 8)
        insetBackgroundView.dropShadow()
    }

    func updateWithDate(_ date: Date) {
        let dateString = TimestampTableViewCell.dateFormatter.string(from: date)
        timestampButton.setTitle(dateString, for: .normal)
    }

    private static let dateFormatter: DateFormatter = {
        let df = DateFormatter()
        df.dateFormat = DateFormatString.EEEE_MMM_dd_yyyy
        return df
    }()
}
