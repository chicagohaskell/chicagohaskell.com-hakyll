{-# LANGUAGE OverloadedStrings #-}

import           Data.Monoid           (mappend)
import           Hakyll
import           Hakyll.Web.Sass       (sassCompiler)
import           System.FilePath.Posix (joinPath, splitPath)


dropRootPath :: Routes
dropRootPath = customRoute $ joinPath . tail . splitPath . toFilePath


main :: IO ()
main = hakyll $ do
    match "assets/images/*" $ do
        route   idRoute
        compile copyFileCompiler

    match "assets/js/*" $ do
        route   idRoute
        compile copyFileCompiler

    match "assets/css/*.css" $ do
        route   idRoute
        compile compressCssCompiler

    match "assets/css/*.scss" $ do
        route   $ setExtension "css"
        compile $ fmap compressCss <$> sassCompiler

    match "content/*.md" $ do
        route $ composeRoutes dropRootPath $ setExtension "html"
        compile $ pandocCompiler
            >>= loadAndApplyTemplate "templates/other.html"   defaultContext
            >>= loadAndApplyTemplate "templates/default.html" defaultContext
            >>= relativizeUrls

    match "content/posts/*.md" $ do
        route $ composeRoutes dropRootPath $ setExtension "html"
        compile $ pandocCompiler
            >>= loadAndApplyTemplate "templates/post.html"        postCtx
            >>= loadAndApplyTemplate "templates/default.html"     postCtx
            >>= relativizeUrls

    create ["archive.html"] $ do
        route idRoute
        compile $ do
            posts <- recentFirst =<< loadAll "content/posts/*"
            let archiveCtx =
                    listField "posts" postCtx (return posts) `mappend`
                    defaultContext

            makeItem ""
                >>= loadAndApplyTemplate "templates/archive.html" archiveCtx
                >>= loadAndApplyTemplate "templates/default.html" archiveCtx
                >>= relativizeUrls

    match "index.html" $ do
        route idRoute
        compile $ do
            posts <- recentFirst =<< loadAll "content/posts/*.md"
            let indexCtx =
                    listField "posts" postCtx (return posts) `mappend`
                    defaultContext

            getResourceBody
                >>= applyAsTemplate indexCtx
                >>= loadAndApplyTemplate "templates/default.html" indexCtx
                >>= relativizeUrls

    match "templates/*" $ compile templateCompiler

postCtx :: Context String
postCtx =
    dateField "date" "%B %e, %Y" `mappend`
    defaultContext
