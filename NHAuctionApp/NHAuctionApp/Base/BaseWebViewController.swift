//
// Created by Sunyoung Choi on 2021/08/27.
//

import WebKit

class BaseWebViewController: BaseViewController {

    //    @IBOutlet weak var baseView: UIView!
    var webView: BaseWKWebView!
    //    var urlString: String?


    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if self.webView != nil && self.webView.isLoading {
            self.webView.stopLoading()
        }
    }
}
