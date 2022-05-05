<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
	String basePath = request.getScheme() + "://" + request.getServerName() + ":" + request.getServerPort() + request.getContextPath() + "/";
%>
<!DOCTYPE html>
<html>
<head>
	<base href="<%=basePath%>">
	<meta charset="UTF-8">

	<link href="jquery/bootstrap_3.3.0/css/bootstrap.min.css" type="text/css" rel="stylesheet" />
	<link href="jquery/bootstrap-datetimepicker-master/css/bootstrap-datetimepicker.min.css" type="text/css" rel="stylesheet" />

	<script type="text/javascript" src="jquery/jquery-1.11.1-min.js"></script>
	<script type="text/javascript" src="jquery/bootstrap_3.3.0/js/bootstrap.min.js"></script>
	<script type="text/javascript" src="jquery/bootstrap-datetimepicker-master/js/bootstrap-datetimepicker.js"></script>
	<script type="text/javascript" src="jquery/bootstrap-datetimepicker-master/locale/bootstrap-datetimepicker.zh-CN.js"></script>

	<link rel="stylesheet" type="text/css" href="jquery/bs_pagination/jquery.bs_pagination.min.css">
	<script type="text/javascript" src="jquery/bs_pagination/jquery.bs_pagination.min.js"></script>
	<script type="text/javascript" src="jquery/bs_pagination/en.js"></script>

<script type="text/javascript">

	$(function(){

		//使用日历插件修改日期
		$(".time").datetimepicker({
			language:  "zh-CN",
			format: "yyyy-mm-dd",//显示格式
			minView: "month",//设置只显示到月份
			autoclose: true,//选中自动关闭
			todayBtn: true, //显示今日按钮
			pickerPosition: "bottom-left"
		});

		//创建activity动态modal
		$("#createBtn").click(function (){

			$.ajax({
				url	:"workbench/activity/getUserList.do",
				type:"get",
				dataType:"json",
				success:function (data){
					/*
						data存放user对象数据userList
					*/
					var html = "";

					$.each(data,function (i,n){

						html += "<option value='"+n.id+"'>"+n.name+"</option>";

					})

					$("#create-owner").html(html);

					//设置下拉菜单的默认值
					//在js中使用el表达式，el表达式一定要套用在字符串中
					var id = "${user.id}";

					$("#create-owner").val(id);

					//显示modal窗口 show hide
					$("#createActivityModal").modal("show");
				}

			})

		})

		//将activity保存到数据库
		$("#saveBtn").click(function (){
			var owner = $.trim($("#create-owner").val());
			var name = $.trim($("#create-name").val());
			var startDate = $.trim($("#create-startDate").val());
			var endDate = $.trim($("#create-endDate").val());
			var cost = $.trim($("#create-cost").val());
			var description = $.trim($("#create-description").val());

			$.ajax({
				url:"workbench/activity/saveActivity.do",
				//data
				data:{
					"owner":owner,
					"name":name,
					"startDate":startDate,
					"endDate":endDate,
					"cost":cost,
					"description":description
				},
				type: "post",
				dataType: "json",
				success: function (data){
					if(data.success){

						/*
						*
						* $("#activityPage").bs_pagination('getOption', 'currentPage')
						* 		操作后停留在当前页
						*
						* $("#activityPage").bs_pagination('getOption', 'rowsPerPage')
						* 		操作后维持已经设置好的每页展现的记录数
						*
						* 这两个参数不需要我们进行任何的修改操作
						* 	直接使用即可
						*
						*
						*
						* */

						//做完添加操作后，应该回到第一页，维持每页展现的记录数
						pageList(1,$("#activityPage").bs_pagination('getOption', 'rowsPerPage'));

					}else{
						alert("添加失败")
					}

					//jquery中reset方法无效  必须调用js原方法
					$(".form-horizontal")[0].reset();

					//执行完创建操作后关闭模态窗口
					$("#createActivityModal").modal("hide");
				}
			})

		})

		//页面加载完毕后触发一个方法
		//默认展开列表的第一页，每页展现两条记录
		pageList(1,2);

		//查询市场活动信息
		$("#searchBtn").click(function (){

			//查询前，将信息保存到隐藏域中
			$("#hidden-name").val($.trim($("#search-name").val()));
			$("#hidden-owner").val($.trim($("#search-owner").val()));
			$("#hidden-startDate").val($.trim($("#search-startDate").val()));
			$("#hidden-endDate").val($.trim($("#search-endDate").val()));

			pageList(1,2)

		})

		//为全选的复选框绑定事件，触发全选操作
		$("#qx").click(function (){
			//prop设置属性值 this在这代表$("input[name=xz]")对象
			$("input[name=xz]").prop("checked",this.checked);
		})

		//以下这种做法是不行的
		/*$("input[name=xz]").click(function () {

			alert(123);

		})*/

		//因为动态生成的元素，是不能够以普通绑定事件的形式来进行操作的
		/*

			动态生成的元素，我们要以on方法的形式来触发事件

			语法：
				$(需要绑定元素的有效的外层元素).on(绑定事件的方式,需要绑定的元素的j
	})
		 */

		//动态生成的元素 用on来绑定事件
		$("#activityBody").on("click",$("input[name=xz]"),function () {

			//
			$("#qx").prop("checked",$("input[name=xz]").length==$("input[name=xz]:checked").length);

		})

		//删除市场活动数据
		$("#deleteBtn").click(function (){

			var $xz = $("input[name=xz]:checked");
			if($xz.length == 0) {
				alert("请选择要删除的记录")
			}else{
				if(confirm("是否要删除？")){

					//得到要删除多条数据的id
					//url:workbench/activity/delete.do?id=xxx&id=xxx&id=xxx
					var param = "";
					for(i=0;i<$xz.length;i++){
						param +="id=";
						//将jquery对象转化为dom对象,再将dom对象转化为jquery对象
						param +=$($xz[i]).val();

						//分割符用&
						//最后条数据不加分割符
						if(i!=$xz.length-1){
							param += "&";
						}
					}
					$.ajax({
						url:"workbench/activity/deleteActivity.do",
						data:param,
						type:"post",
						dataType:"json",
						success:function (data){
							if(data.success){

								//回到第一页，维持每页展现的记录数
								pageList(1,$("#activityPage").bs_pagination('getOption', 'rowsPerPage'));
							}else{
								alert("删除失败")
							}
						}

					})


				}
			}
		})

		//修改市场活动数据modal
		$("#editBtn").click(function (){

			var $xz = $("input[name=xz]:checked");

			if($xz.length==0){
				alert("选择一条数据进行修改")
			}else if($xz.length>1){
				alert("只能选择一条数据进行修改")
			}else{

				//取得修改之前的原信息
				var id = $xz.val();
				$.ajax({
					url:"workbench/activity/getUserListAndActivity.do",
					data:{
						"id":id
					},
					type:"get",
					dataType:"json",
					success:function (data){
						/*
							data：{"uList":[{用户1},{2},..],"a":{市场活动}}
						*/


						//owner下拉框
						var html = "";
						$.each(data.uList,function (i,n){
							html += "<option value='"+n.id+"'>"+n.name+"</option>";
						})
						$("#edit-owner").html(html);

						//修改框原信息
						$("#edit-id").val(data.activity.id);
						$("#edit-name").val(data.activity.name);
						$("#edit-startDate").val(data.activity.startDate);
						$("#edit-endDate").val(data.activity.endDate);
						$("#edit-cost").val(data.activity.cost);
						$("#edit-description").val(data.activity.description);


					}
				})

				//显示modal窗口 show hide
				$("#editActivityModal").modal("show");
			}

		})

		//将修改市场活动结果保存到数据库
		$("#updateBtn").click(function (){

			var id = $.trim($("#edit-id").val());
			var owner = $.trim($("#edit-owner").val());
			var name = $.trim($("#edit-name").val());
			var startDate = $.trim($("#edit-startDate").val());
			var endDate = $.trim($("#edit-endDate").val());
			var cost = $.trim($("#edit-cost").val());
			var description = $.trim($("#edit-description").val());

			$.ajax({
				url:"workbench/activity/updateActivity.do",
				data:{
					"id":id,
					"owner":owner,
					"name":name,
					"startDate":startDate,
					"endDate":endDate,
					"cost":cost,
					"description":description
				},
				type:"post",
				dataType:"json",
				success:function (data){
					/*
					  data:{"success":true/false}
					 */
					if(data.success){
						pageList($("#activityPage").bs_pagination('getOption', 'currentPage')
								,$("#activityPage").bs_pagination('getOption', 'rowsPerPage'));

						//关闭修改操作的模态窗口
						$("#editActivityModal").modal("hide");

					}else{
						alert("数据修改失败")
					}
				}
			})
		})

	})





	/*对于所有的关系型数据库，做前端的分页相关操作的基础组件
	就是pageNo和pageSize
	pageNo:页码
	pageSize:每页展现的记录数


	pageList方法：就是发出ajax请求到后台，从后台取得最新的市场活动信息列表数据
	通过响应回来的数据，局部刷新市场活动信息列表

	我们都在哪些情况下，需要调用pageList方法（什么情况下需要刷新一下市场活动列表）
	（1）点击左侧菜单中的"市场活动"超链接，需要刷新市场活动列表，调用pageList方法
		（2）添加，修改，删除后，需要刷新市场活动列表，调用pageList方法
		（3）点击查询按钮的时候，需要刷新市场活动列表，调用pageList方法
		（4）点击分页组件的时候，调用pageList方法

	以上为pageList方法制定了六个入口，也就是说，在以上6个操作执行完毕后，我们必须要调用pageList方法，刷新市场活动信息列表*/

	function pageList(pageNo,pageSize){

		//将全选的复选框的√干掉
		$("#qx").prop("checked",false);

		//查询前，将隐藏域中保存的信息取出来，重新赋予到搜索框中
		$("#search-name").val($.trim($("#hidden-name").val()));
		$("#search-owner").val($.trim($("#hidden-owner").val()));
		$("#search-startDate").val($.trim($("#hidden-startDate").val()));
		$("#search-endDate").val($.trim($("#hidden-endDate").val()));

		$.ajax({
			url:"workbench/activity/pageList.do",
			data:{
				"name":$.trim($("#search-name").val()),
				"owner":$.trim($("#search-owner").val()),
				"startDate":$.trim($("#search-startDate").val()),
				"endDate":$.trim($("#search-endDate").val()),
				"pageNo":pageNo,
				"pageSize":pageSize
			},
			type:"get",
			dataType:"json",
			success: function (data) {
				/*

					data:vo对象=total+dataList

				*/

				var html = "";
				//每一个n就是每一个市场活动对象
				$.each(data.dataList,function (i,n){
					html += '<tr class="active">';
					html += '<td><input type="checkbox" name="xz" value="'+n.id+'"/></td>';
					html += '<td><a "style=text-decoration: none; cursor: pointer;" onclick="window.location.href=\'workbench/activity/detail.do?id='+n.id+'\';">'+n.name+'</a></td>';
					html += '<td>'+n.owner+'</td>';
					html += '<td>'+n.startDate+'</td>';
					html += '<td>'+n.endDate+'</td>';
					html += '</tr>';

				})

				$("#activityBody").html(html);

				//计算总页数
				var totalPages = data.total%pageSize==0?data.total/pageSize:parseInt(data.total/pageSize)+1;

				//数据处理完毕后，结合分页查询，对前端展现分页信息
				$("#activityPage").bs_pagination({

					currentPage: pageNo, // 页码
					rowsPerPage: pageSize, // 每页显示的记录条数
					maxRowsPerPage: 20, // 每页最多显示的记录条数
					totalPages: totalPages, // 总页数
					totalRows: data.total, // 总记录条数

					visiblePageLinks: 3, // 显示几个卡片

					showGoToPage: true,
					showRowsPerPage: true,
					showRowsInfo: true,
					showRowsDefaultInfo: true,

					//该回调函数时在，点击分页组件的时候触发的
					onChangePage : function(event, data){
						pageList(data.currentPage , data.rowsPerPage);
					}
				});

			}
		})
	}

</script>
	<title></title>
</head>
<body>

	<input type="hidden" id="hidden-name"/>
	<input type="hidden" id="hidden-owner"/>
	<input type="hidden" id="hidden-startDate"/>
	<input type="hidden" id="hidden-endDate"/>

	<!-- 创建市场活动的模态窗口 -->
	<div class="modal fade" id="createActivityModal" role="dialog">
		<div class="modal-dialog" role="document" style="width: 85%;">
			<div class="modal-content">
				<div class="modal-header">
					<button type="button" class="close" data-dismiss="modal">
						<span aria-hidden="true">×</span>
					</button>
					<h4 class="modal-title" id="myModalLabel1">创建市场活动</h4>
				</div>
				<div class="modal-body">

					<form class="form-horizontal" role="form">

						<div class="form-group">
							<label for="create-owner" class="col-sm-2 control-label">所有者<span style="font-size: 15px; color: red;">*</span></label>
							<div class="col-sm-10" style="width: 300px;">
								<select class="form-control" id="create-owner">

								<%--动态生成--%>

								</select>
							</div>
                            <label for="create-Name" class="col-sm-2 control-label">名称<span style="font-size: 15px; color: red;">*</span></label>
                            <div class="col-sm-10" style="width: 300px;">
                                <input type="text" class="form-control" id="create-name">
                            </div>
						</div>

						<div class="form-group">
							<label for="create-startDate" class="col-sm-2 control-label">开始日期</label>
							<div class="col-sm-10" style="width: 300px;">
								<input type="text" class="form-control time" id="create-startDate" readonly>
							</div>
							<label for="create-endDate" class="col-sm-2 control-label">结束日期</label>
							<div class="col-sm-10" style="width: 300px;">
								<input type="text" class="form-control time" id="create-endDate" readonly>
							</div>
						</div>
                        <div class="form-group">

                            <label for="create-cost" class="col-sm-2 control-label">成本</label>
                            <div class="col-sm-10" style="width: 300px;">
                                <input type="text" class="form-control" id="create-cost">
                            </div>
                        </div>
						<div class="form-group">
							<label for="create-description" class="col-sm-2 control-label">描述</label>
							<div class="col-sm-10" style="width: 81%;">
								<textarea class="form-control" rows="3" id="create-description"></textarea>
							</div>
						</div>

					</form>

				</div>
				<div class="modal-footer">
					<button type="button" class="btn btn-default" data-dismiss="modal">关闭</button>
					<button type="button" class="btn btn-primary" id="saveBtn" >保存</button>
				</div>
			</div>
		</div>
	</div>

	<!-- 修改市场活动的模态窗口 -->
	<div class="modal fade" id="editActivityModal" role="dialog">
		<div class="modal-dialog" role="document" style="width: 85%;">
			<div class="modal-content">
				<div class="modal-header">
					<button type="button" class="close" data-dismiss="modal">
						<span aria-hidden="true">×</span>
					</button>
					<h4 class="modal-title" id="myModalLabel2">修改市场活动</h4>
				</div>
				<div class="modal-body">

					<form class="form-horizontal" role="form">

						<!--表中原信息的id-->
						<input type="hidden" id="edit-id"/>

						<div class="form-group">
							<label for="edit-owner" class="col-sm-2 control-label">所有者<span style="font-size: 15px; color: red;">*</span></label>
							<div class="col-sm-10" style="width: 300px;">
								<select class="form-control" id="edit-owner">

								</select>
							</div>
                            <label for="edit-name" class="col-sm-2 control-label">名称<span style="font-size: 15px; color: red;">*</span></label>
                            <div class="col-sm-10" style="width: 300px;">
                                <input type="text" class="form-control" id="edit-name">
                            </div>
						</div>

						<div class="form-group">
							<label for="edit-startDate" class="col-sm-2 control-label">开始日期</label>
							<div class="col-sm-10" style="width: 300px;">
								<input type="text" class="form-control time" id="edit-startDate"  readonly>
							</div>
							<label for="edit-endDate" class="col-sm-2 control-label">结束日期</label>
							<div class="col-sm-10" style="width: 300px;">
								<input type="text" class="form-control time" id="edit-endDate"  readonly>
							</div>
						</div>

						<div class="form-group">
							<label for="edit-cost" class="col-sm-2 control-label">成本</label>
							<div class="col-sm-10" style="width: 300px;">
								<input type="text" class="form-control" id="edit-cost" >
							</div>
						</div>

						<div class="form-group">
							<label for="edit-description" class="col-sm-2 control-label">描述</label>
							<div class="col-sm-10" style="width: 81%;">
								<textarea class="form-control" rows="3" id="edit-description"></textarea>
							</div>
						</div>

					</form>

				</div>
				<div class="modal-footer">
					<button type="button" class="btn btn-default" data-dismiss="modal">关闭</button>
					<button type="button" id="updateBtn" class="btn btn-primary" >更新</button>
				</div>
			</div>
		</div>
	</div>



	<div>
		<div style="position: relative; left: 10px; top: -10px;">
			<div class="page-header">
				<h3>市场活动列表</h3>
			</div>
		</div>
	</div>



	<div style="position: relative; top: -20px; left: 0px; width: 100%; height: 100%;">
		<div style="width: 100%; position: absolute;top: 5px; left: 10px;">

			<div class="btn-toolbar" role="toolbar" style="height: 80px;">
				<form class="form-inline" role="form" style="position: relative;top: 8%; left: 5px;">

				  <div class="form-group">
				    <div class="input-group">
				      <div class="input-group-addon">名称</div>
				      <input class="form-control" type="text" id="search-name">
				    </div>
				  </div>

				  <div class="form-group">
				    <div class="input-group">
				      <div class="input-group-addon">所有者</div>
				      <input class="form-control" type="text" id="search-owner">
				    </div>
				  </div>


				  <div class="form-group">
				    <div class="input-group">
				      <div class="input-group-addon">开始日期</div>
					  <input class="form-control" type="text" id="search-startDate" />
				    </div>
				  </div>
				  <div class="form-group">
				    <div class="input-group">
				      <div class="input-group-addon">结束日期</div>
					  <input class="form-control" type="text" id="search-endDate">
				    </div>
				  </div>

				  <button type="button" id="searchBtn" class="btn btn-default">查询</button>

				</form>
			</div>
			<div class="btn-toolbar" role="toolbar" style="background-color: #F7F7F7; height: 50px; position: relative;top: 5px;">
				<div class="btn-group" style="position: relative; top: 18%;">
				  <button type="button" class="btn btn-primary" id="createBtn" data-target="#createActivityModal"><span class="glyphicon glyphicon-plus"></span> 创建</button>
				  <button type="button" class="btn btn-default" id="editBtn" data-target="#editActivityModal"><span class="glyphicon glyphicon-pencil"></span> 修改</button>
				  <button type="button" class="btn btn-danger"  id="deleteBtn"><span class="glyphicon glyphicon-minus"></span> 删除</button>
				</div>

			</div>
			<div style="position: relative;top: 10px;">
				<table class="table table-hover">
					<thead>
						<tr style="color: #B3B3B3;">
							<td><input type="checkbox" id="qx"/></td>
							<td>名称</td>
                            <td>所有者</td>
							<td>开始日期</td>
							<td>结束日期</td>
						</tr>
					</thead>
					<tbody id="activityBody">
					 <%--动态展现分页查询数据--%>
					</tbody>
				</table>
			</div>

			<div style="height: 50px; position: relative;top: 30px;">
				<div id="activityPage"></div>
			</div>

		</div>

	</div>


</body>
</html>