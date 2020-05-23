module IHP.IDE.CodeGen.View.NewController where

import IHP.ViewPrelude
import IHP.IDE.SchemaDesigner.Types
import IHP.IDE.ToolServer.Types
import IHP.IDE.ToolServer.Layout
import IHP.View.Modal
import IHP.IDE.SchemaDesigner.View.Layout
import qualified IHP.IDE.CodeGen.ControllerGenerator as ControllerGenerator
import qualified Data.Text as Text

data NewControllerView = NewControllerView
    { plan :: Either Text [ControllerGenerator.GeneratorAction]
    , controllerName :: Text
    }

instance View NewControllerView ViewContext where
    html NewControllerView { .. } = [hsx|
        <div class="generators">
            <div class="container pt-5">
                <div class="code-generator new-controller">
                    {if isEmpty then renderEmpty else renderPreview}
                    {unless isEmpty (renderPlan plan)}
                </div>
            </div>
        </div>
    |]
        where
            renderEmpty = [hsx|<form method="POST" action={NewControllerAction} class="d-flex">
                    <input
                        type="text"
                        name="name"
                        placeholder="Controller name"
                        class="form-control"
                        autofocus="autofocus"
                        value={controllerName}
                        />

                    <button class="btn btn-primary" type="submit">Preview</button>
                </form>|]

            renderPreview = [hsx|
                <form method="POST" action={CreateControllerAction} class="d-flex">
                    <div class="controller-name flex-grow-1">{controllerName}</div>

                    <input type="hidden" name="name" value={controllerName}/>

                    <button class="btn btn-primary" type="submit">Generate</button>
                </form>
            |]


            isEmpty = null controllerName

            renderPlan (Left error) = [hsx|{error}|]
            renderPlan (Right actions) = [hsx|<div class="generator-actions">{forEach actions renderGeneratorAction}</div>|]

            renderGeneratorAction ControllerGenerator.CreateFile { .. } = [hsx|
                <div class="generator-action CreateFile">
                    <div class="file-path">{filePath}</div>
                    <div class="file-content">{Text.strip fileContent}</div>
                </div>
            |]
            renderGeneratorAction ControllerGenerator.AppendToFile { .. } = [hsx|
                <div class="generator-action AppendToFile">
                    <div class="file-path">Append to {filePath}</div>
                    <div class="file-content">{Text.strip fileContent}</div>
                </div>
            |]
            renderGeneratorAction ControllerGenerator.AppendToMarker { .. } = [hsx|
                <div class="generator-action AppendToFile">
                    <div class="file-path">Append to {filePath}</div>
                    <div class="file-content">{Text.strip fileContent}</div>
                </div>
            |]
            renderGeneratorAction ControllerGenerator.EnsureDirectory {} = mempty

            renderGeneratorAction action = [hsx|{action}|]