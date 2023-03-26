//
//  WebViewController.swift
//  WebBrowser
//
//  Created by Mereke on 08.03.2023.
//

import UIKit
import WebKit

protocol WebViewDelegate: AnyObject {
    func addToFavorite(_ isFavorite: Bool)
}

class WebViewController: UIViewController {

    weak var delegate: WebViewDelegate?
    private var webView: WKWebView!
    private var activityIndicator: UIActivityIndicatorView!
    var isFavorite: Bool?
    var favoriteIsHidden: Bool = false
    var url: URL?
    private var favouriteButton: UIBarButtonItem!

    init(delegate: WebViewDelegate?) {
        super.init(nibName: nil, bundle: nil)
        self.delegate = delegate
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white

        if let url = url {
            loadURL(url)
        }

        favouriteButton = UIBarButtonItem(image: nil, style: .plain, target: self, action: #selector(addToFavorite))
        favouriteButton.tintColor = .systemBlue
        if !favoriteIsHidden {
            favouriteButton.image = nil
        } else {
            uploadIcon()
        }
        navigationItem.rightBarButtonItem = favouriteButton
        setInterface()
        setConstraints()
    }

    @objc func addToFavorite() {
        if let delegate = delegate, let isFavorite = isFavorite {
            delegate.addToFavorite(!isFavorite)
            updateFavoriteButton(isFavorite: !isFavorite)
        } else {
            print("delegate is nil")
        }
    }
}


extension WebViewController: WKNavigationDelegate {

    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        activityIndicator.startAnimating()
    }

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        activityIndicator.stopAnimating()
    }

    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        activityIndicator.stopAnimating()
    }

    func loadURL(_ url: URL) {
        let request = URLRequest(url: url)
        webView.load(request)
    }

    func uploadIcon() {
        let imageName = isFavorite == true ? "star.fill" : "star"
        favouriteButton.image = UIImage(systemName: imageName)
    }

    func updateFavoriteButton(isFavorite: Bool) {
        self.isFavorite = isFavorite
        uploadIcon()
    }

    private func setInterface() {
        webView = WKWebView(frame: view.bounds)
        webView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        webView.navigationDelegate = self
        activityIndicator = UIActivityIndicatorView(style: .large)
        activityIndicator.color = .black
        view.addSubview(webView)
        view.addSubview(activityIndicator)
    }

    private func setConstraints() {
        webView.snp.makeConstraints {
            $0.edges.equalTo(view.safeAreaLayoutGuide)
        }
        activityIndicator.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
    }

}

