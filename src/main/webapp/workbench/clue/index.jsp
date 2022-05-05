<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
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
			pickerPosition: "top-left"
		});

		//页面加载完毕后触发一个方法
		//默认展开列表的第一页，每页展现两条记录
		pageList(1,2);

		//创建clue动态modal
		$("#createBtn").click(function (){

			$.ajax({
				url	:"workbench/clue/getUserList.do",
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
					$("#createClueModal").modal("show");
				}

			})

		})

		//将clue保存到数据库
		$("#saveBtn").click(function (){
			var fullname = $.trim($("#create-fullname").val());
			var appellation = $.trim($("#create-appellation").val());
			var owner = $.trim($("#create-owner").val());
			var company = $.trim($("#create-company").val());
			var job = $.trim($("#create-job").val());
			var email = $.trim($("#create-email").val());
			var phone = $.trim($("#create-phone").val());
			var website = $.trim($("#create-website").val());
			var mphone = $.trim($("#create-mphone").val());
			var state = $.trim($("#create-state").val());
			var source = $.trim($("#create-source").val());
			var description = $.trim($("#create-description").val());
			var contactSummary = $.trim($("#create-contactSummary").val());
			var nextContactTime = $.trim($("#create-nextContactTime").val());
			var address = $.trim($("#create-address").val());

			$.ajax({
				url:"workbench/clue/saveClue.do",
				data:{
					"fullname":fullname,
					"appellation":appellation,
					"owner":owner,
					"company":company,
					"job":job,
					"email":email,
					"phone":phone,
					"website":website,
					"mphone":mphone,
					"state":state,
					"source":source,
					"description":description,
					"contactSummary":contactSummary,
					"nextContactTime":nextContactTime,
					"address":address
				},
				type: "post",
				dataType: "json",
				success: function (data){
					if(data.success){

						//做完添加操作后，应该回到第一页，维持每页展现的记录数
						pageList(1,$("#cluePage").bs_pagination('getOption', 'rowsPerPage'));

					}else{
						alert("添加失败")
					}

					//jquery中reset方法无效  必须调用js原方法
					$(".form-horizontal")[0].reset();

					//执行完创建操作后关闭模态窗口
					$("#createClueModal").modal("hide");
				}
			})

		})

		//条件查询
		$("#searchBtn").click(function () {
			$("#hidden-fullname").val($.trim($("#search-fullname").val()));
			$("#hidden-owner").val($.trim($("#search-owner").val()));
			$("#hidden-company").val($.trim($("#search-company").val()));
			$("#hidden-phone").val($.trim($("#search-phone").val()));
			$("#hidden-source").val($.trim($("#search-source").val()));
			$("#hidden-mphone").val($.trim($("#search-mphone").val()));
			$("#hidden-state").val($.trim($("#search-state").val()));

			pageList(1,2)
		})

		//为全选的复选框绑定事件，触发全选操作
		$("#qx").click(function (){
			//prop设置属性值 this在这代表$("input[name=xz]")对象
			$("input[name=xz]").prop("checked",this.checked);
		})

		//动态生成的元素 用on来绑定时间
		$("#clueBody").on("click",$("input[name=xz]"),function () {

			//
			$("#qx").prop("checked",$("input[name=xz]").length==$("input[name=xz]:checked").length);

		})

		//删除clue数据
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
						url:"workbench/clue/deleteClue.do",
						data:param,
						type:"post",
						dataType:"json",
						success:function (data){
							if(data.success){

								//回到第一页，维持每页展现的记录数
								pageList(1,$("#cluePage").bs_pagination('getOption', 'rowsPerPage'));
							}else{
								alert("删除失败")
							}
						}

					})


				}
			}
		})

		//编辑clue 模态窗口
		$("#editBtn").click(function (){
			var $xz = $("input[name=xz]:checked");

			if($xz.length==0){
				alert("选择一条数据进行修改")
			}else if($xz.length>1){
				alert("只能选择一条数据进行修改")
			}else {

				//取得修改之前的原信息
				var id = $xz.val();
				$.ajax({
					url: "workbench/clue/getUserListAndClue.do",
					data: {
						"id": id
					},
					type: "get",
					dataType: "json",
					success: function (data) {
						/*
							data：{"uList":[{用户1},{2},..],"c":{clue}}
						*/

						//owner下拉框
						var html = "";
						$.each(data.uList, function (i, n) {
							html += "<option value='" + n.id + "'>" + n.name + "</option>";
						})
						$("#edit-owner").html(html);

						//修改框原信息
						$("#edit-id").val(data.clue.id);
						$("#edit-fullname").val(data.clue.fullname);
						$("#edit-company").val(data.clue.company);
						$("#edit-source").val(data.clue.source);
						$("#edit-state").val(data.clue.state);
						$("#edit-appellation").val(data.clue.appellation);
						$("#edit-owner").val(data.clue.owner);
						$("#edit-job").val(data.clue.job);
						$("#edit-email").val(data.clue.email);
						$("#edit-phone").val(data.clue.phone);
						$("#edit-mphone").val(data.clue.mphone);
						$("#edit-website").val(data.clue.website);
						$("#edit-description").val(data.clue.description);
						$("#edit-contactSummary").val(data.clue.contactSummary);
						$("#edit-nextContactTime").val(data.clue.nextContactTime);
						$("#edit-address").val(data.clue.address);
					}
				})
				$("#editClueModal").modal("show");
			}
		})

		//将修改clue结果保存到数据库
		$("#updateBtn").click(function (){

			var id=$("#edit-id").val();
			var fullname=$("#edit-fullname").val();
			var company=$("#edit-company").val();
			var source=$("#edit-source").val();
			var state=$("#edit-state").val();
			var appellation=$("#edit-appellation").val();
			var owner=$("#edit-owner").val();
			var job=$("#edit-job").val();
			var email=$("#edit-email").val();
			var phone=$("#edit-phone").val();
			var mphone=$("#edit-mphone").val();
			var website=$("#edit-website").val();
			var description=$("#edit-description").val();
			var contactSummary=$("#edit-contactSummary").val();
			var nextContactTime=$("#edit-nextContactTime").val();
			var adress=$("#edit-address").val();

			$.ajax({
				url:"workbench/clue/updateClue.do",
				data:{
					"id":id,
					"fullname":fullname,
					"appellation":appellation,
					"owner":owner,
					"company":company,
					"job":job,
					"email":email,
					"phone":phone,
					"website":website,
					"mphone":mphone,
					"state":state,
					"source":source,
					"description":description,
					"contactSummary":contactSummary,
					"nextContactTime":nextContactTime,
					"address":adress
				},
				type:"post",
				dataType:"json",
				success:function (data){
					/*
					  data:{"success":true/false}
					 */
					if(data.success){

						pageList($("#cluePage").bs_pagination('getOption', 'currentPage')
								,$("#cluePage").bs_pagination('getOption', 'rowsPerPage'));

						//关闭修改操作的模态窗口
						$("#editClueModal").modal("hide");

					}else{
						alert("数据修改失败")
					}
				}
			})
		})

	});


	function pageList(pageNo,pageSize){

		//将全选的复选框的√干掉
		$("#qx").prop("checked",false);

		//查询前，将隐藏域中保存的信息取出来，重新赋予到搜索框中
		$("#search-fullname").val($.trim($("#hidden-fullname").val()));
		$("#search-owner").val($.trim($("#hidden-owner").val()));
		$("#search-company").val($.trim($("#hidden-company").val()));
		$("#search-phone").val($.trim($("#hidden-phone").val()));
		$("#search-source").val($.trim($("#hidden-source").val()));
		$("#search-mphone").val($.trim($("#hidden-mphone").val()));
		$("#search-state").val($.trim($("#hidden-state").val()));

		$.ajax({
			url:"workbench/clue/pageList.do",
			data:{
				"fullname":$("#search-fullname").val(),
				"owner":$("#search-owner").val(),
				"company":$("#search-company").val(),
				"phone":$("#search-phone").val(),
				"mphone":$("#search-mphone").val(),
				"state":$("#search-state").val(),
				"source":$("#search-source").val(),
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
				//每一个n就是每一个clue对象
				$.each(data.dataList,function (i,n){

					html += '<tr class="active">';
					html += '<td><input type="checkbox" name="xz" value="'+n.id+'"/></td>';
					html += '<td><a "style=text-decoration: none; cursor: pointer;" onclick="window.location.href=\'workbench/clue/detail.do?id='+n.id+'\';">'+n.fullname+'</a></td>';
					html += '<td>'+n.company+'</td>';
					html += '<td>'+n.phone+'</td>';
					html += '<td>'+n.mphone+'</td>';
					html += '<td>'+n.source+'</td>';
					html += '<td>'+n.owner+'</td>';
					html += '<td>'+n.state+'</td>';
					html += '</tr>';

				})

				$("#clueBody").html(html);

				//计算总页数
				var totalPages = data.total%pageSize==0?data.total/pageSize:parseInt(data.total/pageSize)+1;

				//数据处理完毕后，结合分页查询，对前端展现分页信息
				$("#cluePage").bs_pagination({

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
</head>
<body>

	<!-- 创建线索的模态窗口 -->
	<div class="modal fade" id="createClueModal" role="dialog">
		<div class="modal-dialog" role="document" style="width: 90%;">
			<div class="modal-content">
				<div class="modal-header">
					<button type="button" class="close" data-dismiss="modal">
						<span aria-hidden="true">×</span>
					</button>
					<h4 class="modal-title" id="myModalLabel">创建线索</h4>
				</div>
				<div class="modal-body">
					<form class="form-horizontal" role="form">
					
						<div class="form-group">
							<label for="create-owner" class="col-sm-2 control-label">所有者<span style="font-size: 15px; color: red;">*</span></label>
							<div class="col-sm-10" style="width: 300px;">
								<select class="form-control" id="create-owner">
								</select>
							</div>
							<label for="create-company" class="col-sm-2 control-label">公司<span style="font-size: 15px; color: red;">*</span></label>
							<div class="col-sm-10" style="width: 300px;">
								<input type="text" class="form-control" id="create-company">
							</div>
						</div>
						
						<div class="form-group">
							<label for="create-appellation" class="col-sm-2 control-label">称呼</label>
							<div class="col-sm-10" style="width: 300px;">
								<select class="form-control" id="create-appellation">
								  <c:forEach items="${appellationList}" var="a">
									  <option vale="${a.value}">${a.text}</option>
								  </c:forEach>
								</select>
							</div>
							<label for="create-fullname" class="col-sm-2 control-label">姓名<span style="font-size: 15px; color: red;">*</span></label>
							<div class="col-sm-10" style="width: 300px;">
								<input type="text" class="form-control" id="create-fullname">
							</div>
						</div>
						
						<div class="form-group">
							<label for="create-job" class="col-sm-2 control-label">职位</label>
							<div class="col-sm-10" style="width: 300px;">
								<input type="text" class="form-control" id="create-job">
							</div>
							<label for="create-email" class="col-sm-2 control-label">邮箱</label>
							<div class="col-sm-10" style="width: 300px;">
								<input type="text" class="form-control" id="create-email">
							</div>
						</div>
						
						<div class="form-group">
							<label for="create-phone" class="col-sm-2 control-label">公司座机</label>
							<div class="col-sm-10" style="width: 300px;">
								<input type="text" class="form-control" id="create-phone">
							</div>
							<label for="create-website" class="col-sm-2 control-label">公司网站</label>
							<div class="col-sm-10" style="width: 300px;">
								<input type="text" class="form-control" id="create-website">
							</div>
						</div>
						
						<div class="form-group">
							<label for="create-mphone" class="col-sm-2 control-label">手机</label>
							<div class="col-sm-10" style="width: 300px;">
								<input type="text" class="form-control" id="create-mphone">
							</div>
							<label for="create-state" class="col-sm-2 control-label">线索状态</label>
							<div class="col-sm-10" style="width: 300px;">
								<select class="form-control" id="create-state">
									<c:forEach items="${clueStateList}" var="c">
										<option vale="${c.value}">${c.text}</option>
									</c:forEach>
								</select>
							</div>
						</div>
						
						<div class="form-group">
							<label for="create-source" class="col-sm-2 control-label">线索来源</label>
							<div class="col-sm-10" style="width: 300px;">
								<select class="form-control" id="create-source">

									<c:forEach items="${sourceList}" var="s">
										<option vale="${s.value}">${s.text}</option>
									</c:forEach>
								</select>
							</div>
						</div>
						

						<div class="form-group">
							<label for="create-description" class="col-sm-2 control-label">线索描述</label>
							<div class="col-sm-10" style="width: 81%;">
								<textarea class="form-control" rows="3" id="create-description"></textarea>
							</div>
						</div>
						
						<div style="height: 1px; width: 103%; background-color: #D5D5D5; left: -13px; position: relative;"></div>
						
						<div style="position: relative;top: 15px;">
							<div class="form-group">
								<label for="create-contactSummary" class="col-sm-2 control-label">联系纪要</label>
								<div class="col-sm-10" style="width: 81%;">
									<textarea class="form-control" rows="3" id="create-contactSummary"></textarea>
								</div>
							</div>
							<div class="form-group">
								<label for="create-nextContactTime" class="col-sm-2 control-label">下次联系时间</label>
								<div class="col-sm-10" style="width: 300px;">
									<input type="text" class="form-control time" id="create-nextContactTime" readonly>
								</div>
							</div>
						</div>
						
						<div style="height: 1px; width: 103%; background-color: #D5D5D5; left: -13px; position: relative; top : 10px;"></div>
						
						<div style="position: relative;top: 20px;">
							<div class="form-group">
                                <label for="create-address" class="col-sm-2 control-label">详细地址</label>
                                <div class="col-sm-10" style="width: 81%;">
                                    <textarea class="form-control" rows="1" id="create-address"></textarea>
                                </div>
							</div>
						</div>
					</form>
					
				</div>
				<div class="modal-footer">
					<button type="button" class="btn btn-default" data-dismiss="modal">关闭</button>
					<button type="button" id="saveBtn" class="btn btn-primary">保存</button>
				</div>
			</div>
		</div>
	</div>
	
	<!-- 修改线索的模态窗口 -->
	<div class="modal fade" id="editClueModal" role="dialog">
		<div class="modal-dialog" role="document" style="width: 90%;">
			<div class="modal-content">
				<div class="modal-header">
					<button type="button" class="close" data-dismiss="modal">
						<span aria-hidden="true">×</span>
					</button>
					<h4 class="modal-title">修改线索</h4>
				</div>
				<div class="modal-body">
					<form class="form-horizontal" role="form">
						<input type="hidden" id="edit-id">
						<div class="form-group">
							<label for="edit-owner" class="col-sm-2 control-label">所有者<span style="font-size: 15px; color: red;">*</span></label>
							<div class="col-sm-10" style="width: 300px;">
								<select class="form-control" id="edit-owner">

								</select>
							</div>
							<label for="edit-company" class="col-sm-2 control-label">公司<span style="font-size: 15px; color: red;">*</span></label>
							<div class="col-sm-10" style="width: 300px;">
								<input type="text" class="form-control" id="edit-company">
							</div>
						</div>
						
						<div class="form-group">
							<label for="edit-appellation" class="col-sm-2 control-label">称呼</label>
							<div class="col-sm-10" style="width: 300px;">
								<select class="form-control" id="edit-appellation">
								  <c:forEach items="${appellationList}" var="a">
									  <option value="${a.value}">${a.text}</option>
								  </c:forEach>
								</select>
							</div>
							<label for="edit-fullname" class="col-sm-2 control-label">姓名<span style="font-size: 15px; color: red;">*</span></label>
							<div class="col-sm-10" style="width: 300px;">
								<input type="text" class="form-control" id="edit-fullname">
							</div>
						</div>
						
						<div class="form-group">
							<label for="edit-job" class="col-sm-2 control-label">职位</label>
							<div class="col-sm-10" style="width: 300px;">
								<input type="text" class="form-control" id="edit-job">
							</div>
							<label for="edit-email" class="col-sm-2 control-label">邮箱</label>
							<div class="col-sm-10" style="width: 300px;">
								<input type="text" class="form-control" id="edit-email">
							</div>
						</div>
						
						<div class="form-group">
							<label for="edit-phone" class="col-sm-2 control-label">公司座机</label>
							<div class="col-sm-10" style="width: 300px;">
								<input type="text" class="form-control" id="edit-phone">
							</div>
							<label for="edit-website" class="col-sm-2 control-label">公司网站</label>
							<div class="col-sm-10" style="width: 300px;">
								<input type="text" class="form-control" id="edit-website">
							</div>
						</div>
						
						<div class="form-group">
							<label for="edit-mphone" class="col-sm-2 control-label">手机</label>
							<div class="col-sm-10" style="width: 300px;">
								<input type="text" class="form-control" id="edit-mphone">
							</div>
							<label for="edit-state" class="col-sm-2 control-label">线索状态</label>
							<div class="col-sm-10" style="width: 300px;">
								<select class="form-control" id="edit-state">
									<c:forEach items="${clueStateList}" var="c">
										<option value="${c.value}">${c.text}</option>
									</c:forEach>
								</select>
							</div>
						</div>
						
						<div class="form-group">
							<label for="edit-source" class="col-sm-2 control-label">线索来源</label>
							<div class="col-sm-10" style="width: 300px;">
								<select class="form-control" id="edit-source">
									<c:forEach items="${sourceList}" var="s">
										<option value="${s.value}">${s.text}</option>
									</c:forEach>
								</select>
							</div>
						</div>
						
						<div class="form-group">
							<label for="edit-description" class="col-sm-2 control-label">描述</label>
							<div class="col-sm-10" style="width: 81%;">
								<textarea class="form-control" rows="3" id="edit-description"></textarea>
							</div>
						</div>
						
						<div style="height: 1px; width: 103%; background-color: #D5D5D5; left: -13px; position: relative;"></div>
						
						<div style="position: relative;top: 15px;">
							<div class="form-group">
								<label for="edit-contactSummary" class="col-sm-2 control-label">联系纪要</label>
								<div class="col-sm-10" style="width: 81%;">
									<textarea class="form-control" rows="3" id="edit-contactSummary"></textarea>
								</div>
							</div>
							<div class="form-group">
								<label for="edit-nextContactTime" class="col-sm-2 control-label">下次联系时间</label>
								<div class="col-sm-10" style="width: 300px;">
									<input type="text" class="form-control time" id="edit-nextContactTime">
								</div>
							</div>
						</div>
						
						<div style="height: 1px; width: 103%; background-color: #D5D5D5; left: -13px; position: relative; top : 10px;"></div>

                        <div style="position: relative;top: 20px;">
                            <div class="form-group">
                                <label for="edit-address" class="col-sm-2 control-label">详细地址</label>
                                <div class="col-sm-10" style="width: 81%;">
                                    <textarea class="form-control" rows="1" id="edit-address"></textarea>
                                </div>
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


	<input type="hidden" id="hidden-fullname"/>
	<input type="hidden" id="hidden-owner"/>
	<input type="hidden" id="hidden-company"/>
	<input type="hidden" id="hidden-phone"/>
	<input type="hidden" id="hidden-source"/>
	<input type="hidden" id="hidden-mphone"/>
	<input type="hidden" id="hidden-state"/>
	<div>
		<div style="position: relative; left: 10px; top: -10px;">
			<div class="page-header">
				<h3>线索列表</h3>
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
				      <input class="form-control" id="search-fullname" type="text">
				    </div>
				  </div>
				  
				  <div class="form-group">
				    <div class="input-group">
				      <div class="input-group-addon">公司</div>
				      <input class="form-control" id="search-company" type="text">
				    </div>
				  </div>
				  
				  <div class="form-group">
				    <div class="input-group">
				      <div class="input-group-addon">公司座机</div>
				      <input class="form-control"id="search-phone" type="text">
				    </div>
				  </div>
				  
				  <div class="form-group">
				    <div class="input-group">
				      <div class="input-group-addon">线索来源</div>
					  <select class="form-control" id="search-source">
						  <c:forEach items="${sourceList}" var="s">
							  <option value="${s.value}">${s.text}</option>
						  </c:forEach>
					  </select>
				    </div>
				  </div>
				  
				  <br>
				  
				  <div class="form-group">
				    <div class="input-group">
				      <div class="input-group-addon">所有者</div>
				      <input class="form-control" id="search-owner" type="text">
				    </div>
				  </div>
				  
				  
				  
				  <div class="form-group">
				    <div class="input-group">
				      <div class="input-group-addon">手机</div>
				      <input class="form-control" id="search-mphone" type="text">
				    </div>
				  </div>
				  
				  <div class="form-group">
				    <div class="input-group">
				      <div class="input-group-addon">线索状态</div>
					  <select class="form-control" id="search-state">
						  <c:forEach items="${clueStateList}" var="c">
							  <option value="${c.value}">${c.text}</option>
						  </c:forEach>
					  </select>
				    </div>
				  </div>

				  <button type="button" id="searchBtn" class="btn btn-default">查询</button>
				  
				</form>
			</div>
			<div class="btn-toolbar" role="toolbar" style="background-color: #F7F7F7; height: 50px; position: relative;top: 40px;">
				<div class="btn-group" style="position: relative; top: 18%;">
				  <button type="button" class="btn btn-primary" id="createBtn"><span class="glyphicon glyphicon-plus"></span> 创建</button>
				  <button type="button" class="btn btn-default" id="editBtn"><span class="glyphicon glyphicon-pencil"></span> 修改</button>
				  <button type="button" class="btn btn-danger" id="deleteBtn"><span class="glyphicon glyphicon-minus"></span> 删除</button>
				</div>
				
				
			</div>
			<div style="position: relative;top: 50px;">
				<table class="table table-hover">
					<thead>
						<tr style="color: #B3B3B3;">
							<td><input type="checkbox" id="qx"/></td>
							<td>名称</td>
							<td>公司</td>
							<td>公司座机</td>
							<td>手机</td>
							<td>线索来源</td>
							<td>所有者</td>
							<td>线索状态</td>
						</tr>
					</thead>
					<tbody id="clueBody">
						<%--<tr>
							<td><input type="checkbox" /></td>
							<td><a style="text-decoration: none; cursor: pointer;" onclick="window.location.href='workbench/clue/detail.jsp';">李四先生</a></td>
							<td>动力节点</td>
							<td>010-84846003</td>
							<td>12345678901</td>
							<td>广告</td>
							<td>zhangsan</td>
							<td>已联系</td>
						</tr>
                        <tr class="active">
                            <td><input type="checkbox" /></td>
                            <td><a style="text-decoration: none; cursor: pointer;" onclick="window.location.href='workbench/clue/detail.jsp';">李四先生</a></td>
                            <td>动力节点</td>
                            <td>010-84846003</td>
                            <td>12345678901</td>
                            <td>广告</td>
                            <td>zhangsan</td>
                            <td>已联系</td>
                        </tr>--%>
						<%--动态展现分页查询数据--%>
					</tbody>
				</table>
			</div>
			
			<div style="height: 50px; position: relative;top: 60px;">
				<div id="cluePage"></div>
			</div>
			
		</div>
		
	</div>

</body>
</html>